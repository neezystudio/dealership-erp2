

class SambazaAPI {

  _SambazaAPIEndpoints endpoints = _SambazaAPIEndpoints();

}

class _SambazaAPIEndpoints {

  String orders([path = '/']) => '/orders$path';

}
