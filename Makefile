# Update the Heroku names to match yours
# Add the HEROKU_API_KEY environment variable to your system
# (and to your CI tool env vars if running in CI)
HEROKU_APP_NAME=radiant-woodland-43340
HEROKU_FRONTEND_APP_NAME=radiant-woodland-frontend
HEROKU_API_KEY=0fc29fe1-c9f1-4411-935c-dbb06a941f8d
COMMIT_ID=$(shell git rev-parse HEAD)

heroku-login:
	HEROKU_API_KEY=${HEROKU_API_KEY} heroku auth:token

heroku-container-login:
	HEROKU_API_KEY=${HEROKU_API_KEY} heroku container:login

build-app-heroku: heroku-container-login
	docker build -t registry.heroku.com/$(HEROKU_APP_NAME)/web ./backend

push-app-heroku: heroku-container-login
	docker push registry.heroku.com/$(HEROKU_APP_NAME)/web

release-heroku: heroku-container-login
	heroku container:release web --app $(HEROKU_APP_NAME)

deploy-frontend-heroku: heroku-login
	cd .. && git subtree push --prefix part-13-docker-deployment/frontend https://heroku:${HEROKU_API_KEY}@git.heroku.com/$(HEROKU_FRONTEND_APP_NAME).git main


.PHONY: heroku-login heroku-container-login build-app-heroku push-app-heroku deploy-frontend-heroku

ready:
	@grep -q '##' .circleci/config.yml && cp .circleci/config.yml config.yml.template && perl -i -pe 's/##//g' .circleci/config.yml

reset:
	@[ -f config.yml.template ] && cat config.yml.template > .circleci/config.yml && rm config.yml.template

setup:
	scripts/setup.sh
