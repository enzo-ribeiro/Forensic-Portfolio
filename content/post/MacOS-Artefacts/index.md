
## Rappel des fichiers

##### .plist
Dans le cours où nous voyons les bases de la forensic sous Mac OS nous avons parler des fichiers ``.plist``, et plus particulièrement des fichiers BLOB. 
Voici un outil supplémentaire pour ouvrir ce type de fichier (dispo sur Mac OS) : 
```Bash 
plutil -p APMExperimentSuiteName.plist 
{
  "APMExperimentFetchSuccessTimestamp" => 1728475253.533066
}
```
Voici un outil disponible sur Linux : 
```Bash
plistutil -p APMExperimentSuiteName.plist 
{
  "APMExperimentFetchSuccessTimestamp" => 1728475253.533066
}
```

##### BDD
Pour naviguer dans les fichiers de base de données nous pouvons utiliser ``DB Browser for SQLite``. Nous pouvons également les extraire et créer des chronologie avec ``apollo`` création de mac4n6 voici le lien du repo ``https://github.com/mac4n6/APOLLO``.

##### Logs
###### Apple System Logs (ASL)
Logs système Apple se trouve à l'emplacement ``/private/var/log/asl/``. Nous pourrons y retrouver les fichiers de logs utmp, wtmp et les détails de connexion. Voici une commande qui nous ouvrira les fichiers de log ASL : ``open -a Console /private/var/log/asl/<log>.asl``.

