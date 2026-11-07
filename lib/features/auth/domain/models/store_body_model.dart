import 'dart:convert';

class StoreBodyModel {
  StoreBodyModel({
    this.translation,
    this.tax,
    this.minDeliveryTime,
    this.maxDeliveryTime,
    this.lat,
    this.lng,
    this.fName,
    this.iban,
    this.lName,
    this.phone,
    this.email,
    this.password,
    this.zoneId,
    this.moduleId,
    this.deliveryTimeType,
    this.businessPlan,
    this.packageId,
    this.pickUpZoneIds,
    this.type,
    this.nationalAddress,
    this.crNumber,
    this.organisationId,
    this.isVatIncluded,
    this.mgmtContact,
    this.mgmtEmail,
    this.mgmtContactMarketing,
    this.mgmtEmailMarketing,
    this.numberOfBranches,
    this.branchName,
    this.branchLocation,
    this.branchCoordinates,
    this.branchContact,
    this.bankName,
    this.beneficiaryName,
    this.accountingEmail,
    this.ownerContactEmail,
    this.managerName,
    this.managerContact,
    this.managerEmail,
    this.vatNumber,
  });

  StoreBodyModel.fromJson(Map<String, dynamic> json) {
    translation = json['translation'];
    tax = json['tax'];
    minDeliveryTime = json['min_delivery_time'];
    maxDeliveryTime = json['max_delivery_time'];
    lat = json['lat'];
    lng = json['lng'];
    iban = json['iban'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    zoneId = json['zone_id'];
    moduleId = json['module_id'];
    deliveryTimeType = json['delivery_time_type'];
    businessPlan = json['business_plan'];
    packageId = json['package_id'];
    if (json['pickup_zone_id'] != null) {
      pickUpZoneIds = json['pickup_zone_id'].cast<String>();
    }
    type = json['type'];
    nationalAddress = json['national_address'];
    crNumber = json['cr_number'];
    organisationId = json['organisation_id_number'];
    isVatIncluded = json['vat_included'];
    mgmtContact = json['management_contact_no'];
    mgmtEmail = json['management_email'];
    mgmtContactMarketing = json['management_contact_no_marketing'];
    mgmtEmailMarketing = json['management_email_marketing'];
    numberOfBranches = json['number_of_branches'];
    branchName = json['branch_name'];
    branchLocation = json['branch_google_map_location'];
    branchCoordinates = json['branch_coordinates'];
    branchContact = json['branch_contact'];
    bankName = json['bank_name'];
    beneficiaryName = json['beneficiary_name'];
    accountingEmail = json['accounting_finance_email'];
    ownerContactEmail = json['owner_contact_email'];
    managerName = json['manager_name'];
    managerContact = json['manager_contact_no'];
    managerEmail = json['manager_contact_email'];
    vatNumber = json['account_vat'];
  }
  String? translation;
  String? tax;
  String? minDeliveryTime;
  String? maxDeliveryTime;
  String? lat;
  String? lng;
  String? fName;
  String? iban;
  String? lName;
  String? phone;
  String? email;
  String? password;
  String? zoneId;
  String? moduleId;
  String? deliveryTimeType;
  String? businessPlan;
  String? packageId;
  List<String>? pickUpZoneIds;

  String? type;

  // New Fields
  String? nationalAddress;
  String? crNumber;
  String? organisationId;
  String? isVatIncluded;
  String? mgmtContact;
  String? mgmtEmail;
  String? mgmtContactMarketing;
  String? mgmtEmailMarketing;
  String? numberOfBranches;
  String? branchName;
  String? branchLocation;
  String? branchCoordinates;
  String? branchContact;
  String? bankName;
  String? beneficiaryName;
  String? accountingEmail;
  String? ownerContactEmail;
  String? managerName;
  String? managerContact;
  String? managerEmail;
  String? vatNumber;

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['translations'] = translation!;
    data['tax'] = tax!;
    data['minimum_delivery_time'] = minDeliveryTime!;
    data['maximum_delivery_time'] = maxDeliveryTime!;
    data['latitude'] = lat!;
    data['longitude'] = lng!;
    data['f_name'] = fName!;
    data['iban'] = iban!;
    data['l_name'] = lName!;
    data['phone'] = phone!;
    data['email'] = email!;
    data['password'] = password!;
    data['zone_id'] = zoneId!;
    data['module_id'] = moduleId!;
    data['delivery_time_type'] = deliveryTimeType!;
    data['business_plan'] = businessPlan ?? '';
    data['package_id'] = packageId!;
    if (pickUpZoneIds != null) {
      data['pickup_zone_id'] = json.encode(pickUpZoneIds);
    }
    if (type != null) {
      data['type'] = type!;
    }
    
    // Add new fields to JSON
    if (nationalAddress != null) data['national_address'] = nationalAddress!;
    if (crNumber != null) data['cr_number'] = crNumber!;
    if (organisationId != null) data['organisation_id_number'] = organisationId!;
    if (isVatIncluded != null) data['vat_included'] = isVatIncluded!;
    if (mgmtContact != null) data['management_contact_no'] = mgmtContact!;
    if (mgmtEmail != null) data['management_email'] = mgmtEmail!;
    if (mgmtContactMarketing != null) data['management_contact_no_marketing'] = mgmtContactMarketing!;
    if (mgmtEmailMarketing != null) data['management_email_marketing'] = mgmtEmailMarketing!;
    if (numberOfBranches != null) data['number_of_branches'] = numberOfBranches!;
    if (branchName != null) data['branch_name'] = branchName!;
    if (branchLocation != null) data['branch_google_map_location'] = branchLocation!;
    if (branchCoordinates != null) data['branch_coordinates'] = branchCoordinates!;
    if (branchContact != null) data['branch_contact'] = branchContact!;
    if (bankName != null) data['bank_name'] = bankName!;
    if (beneficiaryName != null) data['beneficiary_name'] = beneficiaryName!;
    if (accountingEmail != null) data['accounting_finance_email'] = accountingEmail!;
    if (ownerContactEmail != null) data['owner_contact_email'] = ownerContactEmail!;
    if (managerName != null) data['manager_name'] = managerName!;
    if (managerContact != null) data['manager_contact_no'] = managerContact!;
    if (managerEmail != null) data['manager_contact_email'] = managerEmail!;
    if (vatNumber != null) data['account_vat'] = vatNumber!;

    return data;
  }
}
