# pg
docker-compose exec pg /bin/bash
psql -U postgres -d postgres 

# redis
docker-compose exec redis /bin/bash
redis-cli
subscribe msg