# Convenience makefile to build the dev env and run common commands
# Based on https://github.com/niteoweb/Makefile
# .EXPORT_ALL_VARIABLES:
# PIPENV_VENV_IN_PROJECT = 1
# PIPENV_IGNORE_VIRTUALENVS = 1

.PHONY: all
all: .installed

.PHONY: install
install:
	@rm -f .installed  # force re-install
	@make .installed

# TODO: Use pipenv for cleaner solution
# TODO: Check if VIRTUAL_ENV is set, if yes, then deactivate first
.installed: requirements.txt requirements-dev.txt
	@echo "Creating virtualenv .."
	@python -m venv .venv
	@echo "Activating virtualenv .."
	@. .venv/bin/activate
	@echo "Installing packages .."
	@pip install -r requirements.txt
	@echo "Installing dev-packages .."
	@pip install -r requirements-dev.txt
	@echo "Installing pre-commit hooks .."
	@pre-commit install -f --hook-type pre-commit
	@pre-commit install -f --hook-type pre-push
	@echo "This file is used by 'make' for keeping track of last install time. If Pipfile or Pipfile.lock are newer then this file (.installed) then all 'make *' commands that depend on '.installed' know they need to run pipenv install first." \
		> .installed

# Start database in docker in foreground
.PHONY: pgsql
pgsql: .installed
	@docker stop journal-pgsql || true
	@docker rm journal-pgsql || true
	@docker run -it --rm --name journal-pgsql -v $(shell pwd)/.docker:/docker-entrypoint-initdb.d -p 5432:5432 postgres:11.2-alpine \
		postgres -c 'log_statement=all' -c 'max_connections=1000' -c 'log_connections=true'  -c 'log_disconnections=true'  -c 'log_duration=true'

# Start database in docker in background
.PHONY: start-pgsql
start-pgsql: .installed
	@docker start journal-pgsql || docker run -d -v $(shell pwd)/.docker:/docker-entrypoint-initdb.d -p 5432:5432 --name journal-pgsql postgres:11.2-alpine

# Open devdb with pgweb, a fantastic browser-based postgres browser
.PHONY: pgweb
pgweb:
	@docker run -p 8081:8081 --rm -it --link journal-pgsql:journal-pgsql -e "DATABASE_URL=postgres://journal_dev:@journal-pgsql:5432/journal_dev?sslmode=disable" sosedoff/pgweb

.PHONY: clean-pgsql
clean-pgsql: .installed
	@docker stop journal-pgsql || true
	@docker rm journal-pgsql || true

.PHONY: stop-pgsql
stop-pgsql: .installed
	@docker stop journal-pgsql || true

# Run development server
.PHONY: run
run: .installed
	@craft serve

# Testing and linting targets
.PHONY: lint
lint: .installed
	@pre-commit run --all-files --hook-stage push

# .PHONY: types
# types: .installed
# 	# Delete .mypy_cache because mypy report is not generated when cache is fresh https://github.com/python/mypy/issues/5103
# 	@rm -rf .mypy_cache
# 	@pipenv run mypy src/conduit
# 	@cat ./typecov/linecount.txt
# 	@pipenv run typecov 100 ./typecov/linecount.txt

# .PHONY: format
# format: .installed
# 	@pipenv run black src

# anything, in regex-speak
filter = "."

# additional arguments for pytest
unit_test_all = "false"
ifeq ($(filter),".")
	unit_test_all = "true"
endif
ifdef path
	unit_test_all = "false"
endif
args = ""
pytest_args = -k $(filter) $(args)
coverage_args = ""
ifeq ($(unit_test_all),"true")
	coverage_args = --cov=src --cov-branch --cov-report html --cov-report xml:cov.xml --cov-report term-missing --cov-fail-under=100
endif

# Drop, recreate and populate development database with demo content
# Sleep 5 seconds before running migrations, else DB is not ready yet, and migration fails
.PHONY: devdb
devdb:
	@echo "Cleaning pgsql .."
	@make clean-pgsql
	@echo "(Re)Creating Database and User .."
	@make start-pgsql
	@echo "Sleeping for 5 seconds .."
	@sleep 5
	@echo "Creating Tables .."
	@craft migrate

.PHONY: unit
unit: .installed
ifndef path
	@python -m pytest . $(coverage_args) $(pytest_args)
else
	@python -m pytest $(path)
endif

.PHONY: tests
# tests: format lint types unit
tests: lint unit

# TODO: Check if VIRTUAL_ENV is set, if yes, then deactivate first
.PHONY: clean
clean:
	@rm -f ..venv
	@rm -rf .coverage .mypy_cache htmlcov/ htmltypecov typecov xunit.xml \
			.git/hooks/pre-commit .git/hooks/pre-push
	@rm -f .installed
