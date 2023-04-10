enum PrivilegeLevel {
  unauthorized(0),
  guest(10),
  contributor(20),
  maintainer(30),
  owner(40);

  const PrivilegeLevel(this.value);
  final int value;
}
