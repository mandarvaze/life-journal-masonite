## About

Track Fulfillment in your life (https://medium.com/the-book-mechanic/jim-collinss-simple-secret-formula-for-a-fulfilling-life-cd5465d5e8c9)

## Requirements

- Python 3.4 +

## Installation

`make run` will start the development server.

## Testing

`make unit` will run the tests.

## Dockerized Postgres

* `make start-pgsql` to start postgres in the background
* `make pgsql` to start postgres in the foreground - use a separate terminal for this.
* `make devdb` will create DB, tables and demo data from scratch. **All previous data will be lost**

## TODO

- [ ] Fix flake8 errors so that `pre-commit` hooks pass.
- [ ] 100% Test Coverage
- [ ] Configure CI
- [ ] Deploy to Heroku
