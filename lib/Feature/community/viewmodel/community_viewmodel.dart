import 'package:flutter/material.dart';
import '../models/community_comment_model.dart';
import '../models/community_post_model.dart';
import '../services/community_comment_service.dart';
import '../services/community_post_service.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityPostService _postService;
  final CommunityCommentService _commentService = CommunityCommentService();

  CommunityViewModel(this._postService);

  bool isLoading = false;
  bool isCreatingPost = false;
  bool isUpdatingPost = false;
  String? errorMessage;
  String selectedTab = 'all';
  String? currentUserId;

  final Set<String> _likingPostIds = {};
  final Set<String> _loadingCommentsPostIds = {};
  final Set<String> _addingCommentPostIds = {};
  final Set<String> _deletingPostIds = {};
  final Set<String> _updatingCommentIds = {};
  final Set<String> _deletingCommentIds = {};
  final Map<String, List<CommunityCommentModel>> _commentsByPostId = {};

  List<CommunityPostModel> allPosts = [];
  List<CommunityPostModel> myPosts = [];

  // ✅ Search query used to filter displayed posts.
  String _searchQuery = '';

  // ✅ The displayed posts are now filtered based on the current tab + search query.
  List<CommunityPostModel> get displayedPosts {
    final source = selectedTab == 'my' ? myPosts : allPosts;
    return _applySearch(source);
  }

  bool isLikeLoading(String postId) {
    return _likingPostIds.contains(postId);
  }

  bool isCommentsLoading(String postId) {
    return _loadingCommentsPostIds.contains(postId);
  }

  bool isAddingComment(String postId) {
    return _addingCommentPostIds.contains(postId);
  }

  bool isDeletingPost(String postId) {
    return _deletingPostIds.contains(postId);
  }

  bool isUpdatingComment(String commentId) {
    return _updatingCommentIds.contains(commentId);
  }

  bool isDeletingComment(String commentId) {
    return _deletingCommentIds.contains(commentId);
  }

  bool isCurrentUserPost(CommunityPostModel post) {
    return currentUserId != null && post.authorId == currentUserId;
  }

  bool isCurrentUserComment(CommunityCommentModel comment) {
    return currentUserId != null && comment.authorId == currentUserId;
  }

  List<CommunityCommentModel> getCommentsForPost(String postId) {
    return _commentsByPostId[postId] ?? [];
  }

  // ✅ Update search text and refresh UI.
  void updateSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  // ✅ Apply search on content, author name, and disability type.
  List<CommunityPostModel> _applySearch(List<CommunityPostModel> posts) {
    if (_searchQuery.isEmpty) return posts;

    return posts.where((post) {
      final content = post.content.toLowerCase();
      final authorName = post.authorName.toLowerCase();
      final disabilityType = post.disabilityType.toLowerCase();

      return content.contains(_searchQuery) ||
          authorName.contains(_searchQuery) ||
          disabilityType.contains(_searchQuery);
    }).toList();
  }

  Future<void> _reloadPosts() async {
    currentUserId = await _postService.fetchCurrentUserId();
    final results = await Future.wait([
      _postService.fetchAllPosts(),
      _postService.fetchMyPosts(),
    ]);
    allPosts = results[0];
    myPosts = results[1];
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _reloadPosts();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentTab() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (currentUserId == null) {
        currentUserId = await _postService.fetchCurrentUserId();
      }

      if (selectedTab == 'all') {
        allPosts = await _postService.fetchAllPosts();
      } else {
        myPosts = await _postService.fetchMyPosts();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedTab(String value) async {
    if (selectedTab == value) return;

    selectedTab = value;
    notifyListeners();

    if (selectedTab == 'all' && allPosts.isEmpty) {
      await refreshCurrentTab();
    } else if (selectedTab == 'my' && myPosts.isEmpty) {
      await refreshCurrentTab();
    }
  }

  Future<bool> createPost(String content) async {
    isCreatingPost = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _postService.createPost(content: content);
      await _reloadPosts();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String content,
  }) async {
    isUpdatingPost = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _postService.updatePost(
        postId: postId,
        content: content,
      );
      _updatePostContentLocally(postId, content.trim());
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isUpdatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String postId) async {
    if (_deletingPostIds.contains(postId)) return false;

    _deletingPostIds.add(postId);
    errorMessage = null;
    notifyListeners();

    try {
      await _postService.deletePost(postId);
      allPosts = allPosts.where((post) => post.id != postId).toList();
      myPosts = myPosts.where((post) => post.id != postId).toList();
      _commentsByPostId.remove(postId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _deletingPostIds.remove(postId);
      notifyListeners();
    }
  }

  Future<void> toggleLike(CommunityPostModel post) async {
    if (_likingPostIds.contains(post.id)) return;

    _likingPostIds.add(post.id);
    errorMessage = null;
    notifyListeners();

    try {
      if (post.isLikedByCurrentUser) {
        await _postService.unlikePost(post.id);
        _updateLikeState(post.id, false);
      } else {
        await _postService.likePost(post.id);
        _updateLikeState(post.id, true);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _likingPostIds.remove(post.id);
      notifyListeners();
    }
  }

  Future<void> loadComments(String postId) async {
    if (_loadingCommentsPostIds.contains(postId)) return;

    _loadingCommentsPostIds.add(postId);
    errorMessage = null;
    notifyListeners();

    try {
      final comments = await _commentService.fetchComments(postId);
      _commentsByPostId[postId] = comments;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _loadingCommentsPostIds.remove(postId);
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    if (_addingCommentPostIds.contains(postId)) return false;

    _addingCommentPostIds.add(postId);
    errorMessage = null;
    notifyListeners();

    try {
      final newComment = await _commentService.addComment(
        postId: postId,
        content: content,
      );
      final existingComments = _commentsByPostId[postId] ?? [];
      _commentsByPostId[postId] = [...existingComments, newComment];
      _incrementCommentsCount(postId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _addingCommentPostIds.remove(postId);
      notifyListeners();
    }
  }

  Future<bool> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    if (_updatingCommentIds.contains(commentId)) return false;

    _updatingCommentIds.add(commentId);
    errorMessage = null;
    notifyListeners();

    try {
      await _commentService.updateComment(
        commentId: commentId,
        content: content,
      );
      _updateCommentContentLocally(
        postId: postId,
        commentId: commentId,
        newContent: content.trim(),
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _updatingCommentIds.remove(commentId);
      notifyListeners();
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    if (_deletingCommentIds.contains(commentId)) return false;

    _deletingCommentIds.add(commentId);
    errorMessage = null;
    notifyListeners();

    try {
      await _commentService.deleteComment(commentId);
      final existingComments = _commentsByPostId[postId] ?? [];
      _commentsByPostId[postId] = existingComments
          .where((comment) => comment.id != commentId)
          .toList();
      _decrementCommentsCount(postId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _deletingCommentIds.remove(commentId);
      notifyListeners();
    }
  }

  void _updateLikeState(String postId, bool isLikedNow) {
    allPosts = allPosts.map((post) {
      if (post.id != postId) return post;
      final newLikesCount =
      isLikedNow ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
      return post.copyWith(
        isLikedByCurrentUser: isLikedNow,
        likesCount: newLikesCount,
      );
    }).toList();

    myPosts = myPosts.map((post) {
      if (post.id != postId) return post;
      final newLikesCount =
      isLikedNow ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
      return post.copyWith(
        isLikedByCurrentUser: isLikedNow,
        likesCount: newLikesCount,
      );
    }).toList();
  }

  void _incrementCommentsCount(String postId) {
    allPosts = allPosts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(
        commentsCount: post.commentsCount + 1,
      );
    }).toList();

    myPosts = myPosts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(
        commentsCount: post.commentsCount + 1,
      );
    }).toList();
  }

  void _decrementCommentsCount(String postId) {
    allPosts = allPosts.map((post) {
      if (post.id != postId) return post;
      final newCount = post.commentsCount > 0 ? post.commentsCount - 1 : 0;
      return post.copyWith(
        commentsCount: newCount,
      );
    }).toList();

    myPosts = myPosts.map((post) {
      if (post.id != postId) return post;
      final newCount = post.commentsCount > 0 ? post.commentsCount - 1 : 0;
      return post.copyWith(
        commentsCount: newCount,
      );
    }).toList();
  }

  void _updatePostContentLocally(String postId, String newContent) {
    allPosts = allPosts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(content: newContent);
    }).toList();

    myPosts = myPosts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(content: newContent);
    }).toList();
  }

  void _updateCommentContentLocally({
    required String postId,
    required String commentId,
    required String newContent,
  }) {
    final existingComments = _commentsByPostId[postId] ?? [];
    _commentsByPostId[postId] = existingComments.map((comment) {
      if (comment.id != commentId) return comment;
      return comment.copyWith(content: newContent);
    }).toList();
  }

  String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    final weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  }
}