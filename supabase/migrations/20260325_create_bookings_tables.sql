-- This table stores service bookings created by users from the user application.
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  user_id uuid not null references public.people_with_disability(id) on delete cascade,
  institution_id uuid not null references public.institutions(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  requested_date date not null,
  requested_time time not null,
  notes text,
  amount numeric not null check (amount >= 0),
  booking_status text not null default 'pending_payment'
    check (booking_status in ('pending_payment', 'confirmed', 'failed', 'cancelled')),
  payment_method text not null
    check (payment_method in ('card', 'wallet', 'cash_at_institution')),
  payment_status text not null default 'pending'
    check (payment_status in ('pending', 'success', 'failed', 'cash_due')),
  paymob_order_id text,
  paymob_intention_id text,
  confirmed_at timestamptz,
  cancelled_at timestamptz
);

-- This table stores payment records linked to service bookings.
create table if not exists public.booking_payments (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  provider text not null
    check (provider in ('paymob', 'manual')),
  payment_method text not null
    check (payment_method in ('card', 'wallet', 'cash_at_institution')),
  payment_status text not null default 'pending'
    check (payment_status in ('pending', 'success', 'failed', 'cash_due')),
  amount numeric not null check (amount >= 0),
  transaction_ref text,
  paymob_order_id text,
  paymob_intention_id text,
  paymob_transaction_id text
);

-- This index speeds up fetching bookings by user.
create index if not exists idx_bookings_user_id
on public.bookings(user_id);

-- This index speeds up fetching bookings by institution.
create index if not exists idx_bookings_institution_id
on public.bookings(institution_id);

-- This index speeds up fetching bookings by service.
create index if not exists idx_bookings_service_id
on public.bookings(service_id);

-- This index speeds up filtering bookings by booking status.
create index if not exists idx_bookings_booking_status
on public.bookings(booking_status);

-- This index speeds up fetching payment records by booking.
create index if not exists idx_booking_payments_booking_id
on public.booking_payments(booking_id);

-- This index speeds up filtering booking payments by payment status.
create index if not exists idx_booking_payments_payment_status
on public.booking_payments(payment_status);

-- This statement enables RLS on the bookings table.
alter table public.bookings enable row level security;

-- This statement enables RLS on the booking payments table.
alter table public.booking_payments enable row level security;

-- This policy allows users to read only their own bookings.
create policy "Users can view their own bookings"
on public.bookings
for select
using (auth.uid() = user_id);

-- This policy allows users to create bookings only for themselves.
create policy "Users can insert their own bookings"
on public.bookings
for insert
with check (auth.uid() = user_id);

-- This policy allows users to read payment rows only for their own bookings.
create policy "Users can view payment rows for their own bookings"
on public.booking_payments
for select
using (
  exists (
    select 1
    from public.bookings b
    where b.id = booking_id
      and b.user_id = auth.uid()
  )
);
