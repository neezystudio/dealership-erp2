abstract class SambazaCache<T, E> {

  bool has(T key);

  E $get(T key);

  void $set(T key, E value);

}