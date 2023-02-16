class UserDetails {
  final String? name;
  final double? balance;
  final String? email;
  final String? phone;
  final String? pfp;
  final String? address;
  UserDetails({
    this.name,
    this.balance,
    this.email,
    this.phone,
    this.pfp,
    this.address
  });
  UserDetails copyWith({
    String? name,
    double? balance,
    String? email,
    String? phone,
    String? pfp,
    String? address
  }) {
    return UserDetails(
      name: name ?? this.name,
      balance: balance ?? this.balance,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pfp: pfp ?? this.pfp,
      address: address ?? this.address
    );
  }
}