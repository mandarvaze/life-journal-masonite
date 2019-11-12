from orator.orm import Factory

from app.Entry import Entry
from app.User import User

factory = Factory()


def users_factory(faker):
    return {
        "name": faker.name(),
        "email": faker.email(),
        "password": "$2b$12$WMgb5Re1NqUr.uSRfQmPQeeGWudk/8/aNbVMpD1dR.Et83vfL8WAu",  # == 'secret'
    }


def entries_factory(faker):

    import random

    author_ids = [user.id for user in User.select("id").get()]
    entry_dates = [
        entry.entry_for_date for entry in Entry.select("entry_for_date").get()
    ]

    entry_date = faker.date_between(start_date="-7d", end_date="today")
    while entry_date in entry_dates:
        entry_date = faker.date_between(start_date="-7d", end_date="today")

    return {
        "note": faker.sentence(nb_words=6),
        "rating": faker.random_int(min=-2, max=2),
        "entry_for_date": entry_date,
        "author_id": random.randint(0, len(author_ids)),
    }


factory.register(User, users_factory)
factory.register(Entry, entries_factory)