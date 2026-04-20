abstract interface class EntityRepository<T> {
  Future<List<T>> load();

  Future<void> save(List<T> entities);
}
