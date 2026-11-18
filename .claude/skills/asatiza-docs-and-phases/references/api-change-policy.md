# API Change Policy

Read this before any phase that touches Supabase (tables, views, RPC/Postgres functions, Edge Functions, Storage, Realtime, Auth) or, later, the Python FastAPI.

Document:

- Supabase: table/view, columns, types, nullability, defaults, RLS policies (select/insert/update/delete) per role, triggers, RPC function signature and security (`security definer`/`invoker`), Edge Function name, method, auth header, request body, response body, error responses, Storage bucket, path pattern, bucket policies, Realtime channel/filter, existing callers, affected screens, and backward compatibility.
- Python API (later): endpoint, HTTP method, Supabase JWT verification, headers, path/query parameters, request/response models, required/optional fields, nullability, success/error codes, pagination, timeout, retry, cache behavior.

Rules:

- Do not invent tables, columns, functions, buckets or API fields.
- Do not silently change column names, types, nullability, RLS policies, function signatures, bucket paths, Realtime filters or auth handling.
- Use the existing repository interfaces, `Supabase*Repository` implementations, model `fromJson/toJson` conventions and failure mapping.
- Every schema change ships as a new `supabase/migrations/YYYYMMDDHHMMSS_short_description.sql` file; never edit an applied migration.
- Never use the Supabase `service_role` key in the app. Privileged work goes in Edge Functions or `security definer` functions with explicit checks.
- Record every table, function, Edge Function, bucket and channel in `docs/API_REFERENCE.md` and `docs/DATABASE_AND_CACHE.md`.
- Never deploy migrations or functions to the remote Supabase project unless the developer explicitly asks for that specific action.
- When the contract is unclear and developer information is needed, keep status `PLANNED` or `ACTIVE`, set step to `ANALYSIS`, and record the missing information.
- When backend support, project access or credentials are unavailable externally, set status to `CLOSED`, set outcome to `BLOCKED`, and update the state snapshot.
- Treat authentication, OTP, RLS, Storage policies, Edge Functions, Realtime, account deletion and shared repository interfaces as high risk.
