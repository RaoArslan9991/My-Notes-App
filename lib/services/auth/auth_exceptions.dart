//loginView Exceptions

class UserNotFoundAuthException implements Exception{}
//below is for invalid cresentials
class WrondPasswordAuthException implements Exception{}


//registerView Exceptions

class WeakPasswordAuthException implements Exception{}
class EmailAlreadyInUseAuthException implements Exception{}
class InvalidEmailAuthException implements Exception{}

//Generic exceptions

class GenericAuthException implements Exception{}
class UserNotLoggedInAuthException implements Exception{}

