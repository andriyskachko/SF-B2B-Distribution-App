public with sharing class Territory2Controller {
  public static List<UserDTO> getUsersInTerritoryByRole(
    Id territory2Id,
    String role
  ) {
    List<UserTerritory2Association> lstUserTerritory2Association = [
      SELECT UserId, User.Name
      FROM UserTerritory2Association
      WHERE Territory2Id = :territory2Id AND RoleInTerritory2 = :role
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    List<UserDTO> lstUser = new List<UserDTO>();

    for (UserTerritory2Association uta : lstUserTerritory2Association) {
      UserDTO user = new UserDTO();
      user.id = uta.UserId;
      user.name = uta.User.Name;
      lstUser.add(user);
    }

    return lstUser;
  }

  public static Map<Id, Set<String>> getTerritory2UsersMapByRole(String role) {
    Map<Id, Set<String>> mapTerritory2Users = new Map<Id, Set<String>>();

    List<Territory2> lstTerritory2 = [
      SELECT Id, Name
      FROM Territory2
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    List<UserTerritory2Association> lstUserTerritory2Association = [
      SELECT UserID, Territory2Id
      FROM UserTerritory2Association
      WHERE RoleInTerritory2 = :role
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Territory2 t : lstTerritory2) {
      Set<String> userIdSet = new Set<String>();
      for (UserTerritory2Association uta : lstUserTerritory2Association) {
        if (uta.Territory2Id == t.Id) {
          userIdSet.add(uta.UserId);
        }
      }
      mapTerritory2Users.put(t.Id, userIdSet);
    }

    return mapTerritory2Users;
  }
}