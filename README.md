Oslo bysykkel
=============

> La oss se om det faktisk blir fylt på sykler på Bjølsen


# Utvikling lokalt

Trenger en Postgres-database. Kan kjøres opp lokalt med Docker:
```bash
docker run --name postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=oslobyskkel -p 5432:5432 -d postgres:latest
```

Har du allerede en Postgres-container kjørende, så kan du bruke følgende kommando for å legge til en ny database:
```bash
docker exec -it postgres psql -U postgres -c "CREATE DATABASE oslobysykkel"
```

Så installerer du Ruby-versjonen du finner i `.ruby-verison`, og installerer Gems med `bundle install`.

Du starter bot'en og web-appen med `foreman start`. Den vil se etter `SLACK_API_TOKEN` i `.env`-fil.

Ønsker du kun å kjøre bot'en eller web-appen, så kan du legge til `bot` eller `web` etter `foreman start`.