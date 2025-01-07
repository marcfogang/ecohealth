// lib/src/data/services/medication_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medication_details_15.dart';

/// Modèle basique pour la recherche par brand_name
class MedicationBasicInfo {
  final String brandName; // nom_de_marque
  final String className; // nom_de_classe
  final String descriptor; // descripteur
  final String drugCode;  // code_médicament
  final String din;       // numéro_d'identification_du_médicament
  final String aisCount;  // nombre_de_ais

  MedicationBasicInfo({
    required this.brandName,
    required this.className,
    required this.descriptor,
    required this.drugCode,
    required this.din,
    required this.aisCount,
  });
}

class MedicationApiService {
  final String baseUrl = 'https://produits-sante.canada.ca/api/drug';

  /// ===================== 1) Recherche Basique  =====================
  /// Filtrage côté client par le brand_name
  Future<List<MedicationBasicInfo>> searchMedications(String query, {String lang = 'fr'}) async {
    final url = Uri.parse('$baseUrl/drugproduct/?lang=$lang&type=json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);

      final filtered = list.where((item) {
        final brand = (item['brand_name'] ?? '').toString().toLowerCase();
        return brand.contains(query.toLowerCase());
      });

      return filtered.map((item) {
        return MedicationBasicInfo(
          brandName: (item['brand_name'] ?? '').toString(),
          className: (item['class_name'] ?? '').toString(),
          descriptor: (item['descriptor'] ?? '').toString(),
          drugCode: (item['drug_code'] ?? '').toString(),
          din: (item['drug_identification_number'] ?? '').toString(),
          aisCount: (item['number_of_ais'] ?? '').toString(),
        );
      }).toList();
    } else {
      throw Exception("Échec de la récupération (code ${response.statusCode})");
    }
  }

  /// ===================== 2) Récupération Complète (15 champs) =====================
  Future<MedicationDetails15> fetchMedicationDetails(String drugCode, {String lang = 'fr'}) async {
    // 2.1) drugproduct => (nom_de_marque, nom_de_classe, descripteur, code_médicament, numero_d_identification, nombre_de_ais)
    final productUrl = Uri.parse('$baseUrl/drugproduct/?lang=$lang&type=json');
    final productResp = await http.get(productUrl);

    if (productResp.statusCode != 200) {
      throw Exception('Échec fetch drugproduct');
    }

    final List<dynamic> productList = jsonDecode(productResp.body);
    final productData = productList.firstWhere(
          (p) => p['drug_code'].toString() == drugCode,
      orElse: () => null,
    );
    if (productData == null) {
      throw Exception("Aucun produit trouvé (drug_code=$drugCode)");
    }

    final nomDeMarque = (productData['brand_name'] ?? '').toString();
    final nomDeClasse = (productData['class_name'] ?? '').toString();
    final descripteur = (productData['descriptor'] ?? '').toString();
    final codeMedicament = (productData['drug_code'] ?? '').toString();
    final numeroIdentificationMedicament = (productData['drug_identification_number'] ?? '').toString();
    final nombreDeAis = (productData['number_of_ais'] ?? '').toString();

    // 2.2) form => nom_forme_pharmaceutique
    final formUrl = Uri.parse('$baseUrl/form/?lang=$lang&type=json');
    final formResp = await http.get(formUrl);
    String nomFormePharmaceutique = '';
    if (formResp.statusCode == 200) {
      final List<dynamic> formList = jsonDecode(formResp.body);
      final matchingForms = formList.where((f) => f['drug_code'].toString() == drugCode);
      nomFormePharmaceutique =
          matchingForms.map((f) => f['pharmaceutical_form_name']?.toString() ?? '').join(', ');
    }

    // 2.3) packaging => (type_de_paquet, informations_sur_le_produit, CUP)
    final packUrl = Uri.parse('$baseUrl/packaging/?type=json');
    final packResp = await http.get(packUrl);
    String typeDePaquet = '';
    String informationsSurLeProduit = '';
    String cup = '';
    if (packResp.statusCode == 200) {
      final List<dynamic> packList = jsonDecode(packResp.body);
      final matchingPacks = packList.where((p) => p['drug_code'].toString() == drugCode);
      typeDePaquet = matchingPacks.map((p) => (p['package_type'] ?? '').toString()).join(', ');
      informationsSurLeProduit = matchingPacks.map((p) => (p['product_information'] ?? '').toString()).join(', ');
      cup = matchingPacks.map((p) => (p['upc'] ?? '').toString()).join(', ');
    }

    // 2.4) route => (nom_de_la_voie_administrative)
    final routeUrl = Uri.parse('$baseUrl/route/?lang=$lang&type=json');
    final routeResp = await http.get(routeUrl);
    String nomDeLaVoieAdministrative = '';
    if (routeResp.statusCode == 200) {
      final List<dynamic> routeList = jsonDecode(routeResp.body);
      final matchRoute = routeList.where((r) => r['drug_code'].toString() == drugCode);
      nomDeLaVoieAdministrative =
          matchRoute.map((r) => (r['route_of_administration_name'] ?? '').toString()).join(', ');
    }

    // 2.5) schedule => (nom_du_programme)
    final scheduleUrl = Uri.parse('$baseUrl/schedule/?lang=$lang&type=json');
    final scheduleResp = await http.get(scheduleUrl);
    String nomDuProgramme = '';
    if (scheduleResp.statusCode == 200) {
      final List<dynamic> scheduleList = jsonDecode(scheduleResp.body);
      final matchSchedule = scheduleList.where((s) => s['drug_code'].toString() == drugCode);
      nomDuProgramme = matchSchedule.map((s) => (s['schedule_name'] ?? '').toString()).join(', ');
    }

    // 2.6) status => (date_d'expiration, historique_date)
    final statusUrl = Uri.parse('$baseUrl/status/?lang=$lang&type=json');
    final statusResp = await http.get(statusUrl);
    String dateExpiration = '';
    String historiqueDate = '';
    if (statusResp.statusCode == 200) {
      final List<dynamic> stList = jsonDecode(statusResp.body);
      final matchStatus = stList.where((s) => s['drug_code'].toString() == drugCode);
      dateExpiration = matchStatus.map((s) => (s['expiration_date'] ?? '').toString()).join(', ');
      historiqueDate = matchStatus.map((s) => (s['history_date'] ?? '').toString()).join(', ');
    }

    // 2.7) therapeuticclass => (nom_espèce_vétérinaire = tc_atc)
    final tclassUrl = Uri.parse('$baseUrl/therapeuticclass/?lang=$lang&type=json');
    final tclassResp = await http.get(tclassUrl);
    String nomEspeceVeterinaire = '';
    if (tclassResp.statusCode == 200) {
      final List<dynamic> tcList = jsonDecode(tclassResp.body);
      final matchTC = tcList.where((tc) => tc['drug_code'].toString() == drugCode);
      // on suppose "tc_atc" = nom_espèce_vétérinaire
      nomEspeceVeterinaire = matchTC.map((tc) => (tc['tc_atc'] ?? '').toString()).join(', ');
    }

    // Construire l’objet final
    return MedicationDetails15(
      nomEspeceVeterinaire: nomEspeceVeterinaire,
      dateExpiration: dateExpiration,
      historiqueDate: historiqueDate,
      nomDuProgramme: nomDuProgramme,
      nomDeLaVoieAdministrative: nomDeLaVoieAdministrative,
      typeDePaquet: typeDePaquet,
      informationsSurLeProduit: informationsSurLeProduit,
      cup: cup,
      nomFormePharmaceutique: nomFormePharmaceutique,
      nomDeMarque: nomDeMarque,
      nomDeClasse: nomDeClasse,
      descripteur: descripteur,
      codeMedicament: codeMedicament,
      numeroIdentificationMedicament: numeroIdentificationMedicament,
      nombreDeAis: nombreDeAis,
    );
  }
}
