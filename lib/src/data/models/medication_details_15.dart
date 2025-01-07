// lib/src/data/models/medication_details_15.dart

/// Modèle contenant EXACTEMENT les 15 champs demandés
class MedicationDetails15 {
  // (1) nom_espèce_vétérinaire
  final String nomEspeceVeterinaire;

  // (2) date_d'expiration
  final String dateExpiration;

  // (3) historique_date
  final String historiqueDate;

  // (4) nom_du_programme
  final String nomDuProgramme;

  // (5) nom_de_la_voie_administrative
  final String nomDeLaVoieAdministrative;

  // (6) type_de_paquet
  final String typeDePaquet;

  // (7) informations_sur_le_produit
  final String informationsSurLeProduit;

  // (8) CUP
  final String cup;

  // (9) nom_forme_pharmaceutique
  final String nomFormePharmaceutique;

  // (10) nom_de_marque
  final String nomDeMarque;

  // (11) nom_de_classe
  final String nomDeClasse;

  // (12) descripteur
  final String descripteur;

  // (13) code_médicament
  final String codeMedicament;

  // (14) numéro_d'identification_du_médicament
  final String numeroIdentificationMedicament;

  // (15) nombre_de_ais
  final String nombreDeAis;

  MedicationDetails15({
    required this.nomEspeceVeterinaire,
    required this.dateExpiration,
    required this.historiqueDate,
    required this.nomDuProgramme,
    required this.nomDeLaVoieAdministrative,
    required this.typeDePaquet,
    required this.informationsSurLeProduit,
    required this.cup,
    required this.nomFormePharmaceutique,
    required this.nomDeMarque,
    required this.nomDeClasse,
    required this.descripteur,
    required this.codeMedicament,
    required this.numeroIdentificationMedicament,
    required this.nombreDeAis,
  });
}
