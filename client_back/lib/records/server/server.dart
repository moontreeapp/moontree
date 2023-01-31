/// server objects get saved as these objects in cache. therefore, these objects
/// must have all the same fields as the server objects, and can have more for
/// convenience on joining to other objects usually.
/// 
/// right now we save everything as a CachedServerObject. it's easily translated
/// to it's corresponding server object because we just save it as a json string
/// with some identifying nullable information.
/// 
/// in the future we may make objects that match the server objects exactly, but
/// for now that is not necessary.