class Address{
  String id;
  String label;
  String name;
  String phoneNumber;
  String fullAddress;
  Map<String, dynamic> pinpoint;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phoneNumber,
    required this.fullAddress,
    required this.pinpoint,

});

  factory Address.fromJson(Map<String,dynamic> json) {
    return Address(
      id: json['id'],
      label: json['label'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      fullAddress: json['fullAddress'],
      pinpoint: json['pinpoint'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'id' : id,
      'label' : label,
      'name' : name,
      'phoneNumber' : phoneNumber,
      'fullAddress' : fullAddress,
      'pinpoint' : pinpoint
    };
  }
}