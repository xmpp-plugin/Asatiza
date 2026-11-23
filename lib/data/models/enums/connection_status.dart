/// Lifecycle of a connection request (plan section 4: chat only after
/// [accepted]).
enum ConnectionStatus { pending, accepted, declined, removed }
