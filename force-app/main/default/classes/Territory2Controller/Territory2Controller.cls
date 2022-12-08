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
}
