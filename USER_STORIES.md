# User Stories — Vigie

---

## US1 — Surveillance de la carte

**Rôle** : Agent municipal
**Besoin** : En tant qu'agent municipal, je veux visualiser d'un coup d'œil l'état de l'ensemble du parc sur une carte interactive, afin de prioriser mes interventions sans avoir à parcourir un tableau de données.
**Valeur métier** : Réduire le temps de décision avant chaque tournée en rendant l'information spatiale immédiatement lisible.

### Critères d'acceptation

**Carte et marqueurs**
- La carte affiche l'ensemble des PAVs sous forme de marqueurs colorés selon leur taux de remplissage : vert (< 50 %), orange (50–80 %), rouge (> 80 %), gris (données absentes ou inconnues)
- Un badge rouge persistant signale les PAVs dont le taux dépasse 90 %, indiquant une situation critique
- Les statistiques globales du parc (nombre de PAVs, taux de remplissage moyen, nombre d'incidents ouverts) sont affichées en permanence dans un overlay sur la carte
- Le nombre de marqueurs visibles se met à jour en temps réel lors du filtrage

**Filtres et recherche**
- Un filtre par type de déchet permet de n'afficher que les PAVs d'une catégorie donnée
- Un filtre par niveau de remplissage permet d'isoler les PAVs faibles, moyens, élevés ou sans données
- Un champ de recherche permet de retrouver un PAV par son nom ou son identifiant, sans aller-retour serveur
- Un paramètre d'URL (`?focus=pav-id`) permet d'ouvrir directement le panneau d'un PAV au chargement de la page

**Panneau PAV**
- Un clic sur un marqueur ouvre un panneau latéral affichant les détails du PAV : nom, adresse, type de déchet, taux de remplissage actuel, indicateur de fraîcheur de la dernière lecture
- Le panneau est organisé en 4 onglets : timeline unifiée (tous événements chronologiques), relevés capteurs, dépôts badge, incidents
- Chaque onglet est paginé indépendamment
- Un graphique Chart.js affiche l'évolution du taux de remplissage sur les 30 derniers jours
- Si la dernière lecture capteur date de plus d'une semaine, un indicateur visuel en rouge signale l'ancienneté des données

---

## US2 — Gestion des incidents

**Rôle** : Responsable de collecte
**Besoin** : En tant que responsable de collecte, je veux consulter les incidents ouverts sur chaque PAV et les marquer comme résolus depuis le panneau ou la liste globale, afin de tracer le traitement de chaque anomalie du signalement à la clôture.
**Valeur métier** : Garantir qu'aucun incident ne reste sans suivi et fournir un historique traçable pour les audits et les rapports.

### Critères d'acceptation

**Liste des incidents**
- La page incidents liste tous les incidents avec leur statut (ouvert / résolu), le PAV concerné, la date et la description
- Un filtre par statut permet d'afficher tous les incidents, uniquement les ouverts ou uniquement les résolus
- Un filtre par PAV et des filtres de dates (du / au) permettent de restreindre la liste
- La liste est paginée
- Les incidents liés à un PAV dont le taux de remplissage dépasse 90 % sont mis en évidence visuellement

**Actions sur un incident**
- Chaque incident peut être résolu ou réouvert depuis la liste globale ou depuis l'onglet incidents du panneau PAV
- L'action de résolution demande une confirmation avant d'être appliquée
- Après résolution ou réouverture, l'utilisateur reste sur la vue depuis laquelle il a agi, sans redirection inattendue
- Une note textuelle peut être ajoutée ou modifiée sur n'importe quel incident ; la sauvegarde se fait sans rechargement de page via Turbo Stream

**Export**
- La liste filtrée peut être exportée en CSV avec les colonnes : PAV, identifiant, date, description, statut

---

## US3 — Planification de tournée

**Rôle** : Agent de terrain
**Besoin** : En tant qu'agent de terrain, je veux obtenir automatiquement l'itinéraire le plus court pour vider tous les PAVs dont le taux de remplissage dépasse un seuil défini, afin de minimiser le temps de déplacement lors d'une tournée de collecte.
**Valeur métier** : Optimiser les tournées de collecte en éliminant la planification manuelle et en réduisant les kilomètres parcourus inutilement.

### Critères d'acceptation

**Sélection des PAVs**
- La page `/tours` affiche une carte Leaflet plein écran avec l'ensemble des PAVs
- Un slider permet de définir le seuil de remplissage (50–100 %, valeur par défaut : 70 %) : les PAVs au-dessus du seuil sont automatiquement sélectionnés et affichés en couleur (vert / orange / rouge selon le taux), les autres sont grisés
- Le nombre de PAVs sélectionnés est affiché en temps réel dans le panneau de contrôle
- Un PAV peut être ajouté ou retiré manuellement de la sélection en cliquant sur son marqueur
- Modifier le seuil ou cliquer sur un marqueur efface la tournée calculée et réinitialise l'affichage

**Calcul de l'itinéraire**
- Le bouton "Calculer l'itinéraire" est désactivé tant que moins de 2 PAVs sont sélectionnés
- Au clic, l'API OSRM (router.project-osrm.org) calcule un itinéraire optimisé sur routes réelles — source=first, destination=last, roundtrip=false
- L'itinéraire calculé est tracé sur la carte sous forme de polyline en pointillés animés
- Les marqueurs des PAVs dans la tournée affichent leur numéro d'ordre de passage
- La distance totale estimée (en mètres ou en kilomètres selon la valeur) est affichée dans le panneau
- La liste ordonnée des PAVs à visiter (nom + taux de remplissage) est affichée dans le panneau
- La page est accessible depuis la navigation principale
