/// cache is responsible for saving data to cache. things we save to cache are
/// saved in hive boxes so they can be persistent across sessions so much of 
/// what cache is tasked to do is translate the server object to the local 
/// object and save to cache. repos call this.


/// IMPORTANT:
/// instead of caching the domain as we did in v1 we should cache things in the
/// same structure as the server data, then translate to the domain after we get
/// the data from either cache or server.
