"""Entries Table Seeder.

You can run this seeder in order to generate journal entries.

    - Each time it is ran it will generate 5 random entries.
    - You can run the seeder by running: craft seed:run.
"""

from orator.seeds import Seeder

from app.Entry import Entry
from config.factories import factory


class EntryTableSeeder(Seeder):
    def run(self):
        """
        Run the database seeds.
        """
        factory(Entry, 25).create()
