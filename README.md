# Hardening-as-Code
 A static and dynamic hardening for critical Linux  system components.
 
 Entrée Utilisateur (main.sh) 
├── Mise à jour du système (update_system) 
├── Durcissement Statique (show_static_modules) 
│  ├── auth.sh 
│  ├── FileSystem.sh 
│  ├── kernel.sh 
│  ├── material.sh 
│  ├── partition.sh 
│  └── network.sh 
├── Durcissement Dynamique (show_dynamic_modules) 
│  ├── auth-dynamic.sh 
│  ├── FS-dynamic.sh 
│  ├── kernel-dynamic.sh 
│  ├── material-dynamic.sh 
│  ├── partition-dynamic.sh 
│  └── network-dynamic.sh 
├── Vérification de l'État du Système (check_system_status) 
│  ├── Affichage des utilisateurs connectés 
│  ├── Vérifications disque et mémoire 
│  ├── Vérification des services actifs 
│  └── Contrôle des permissions critiques 
└── Quitter
