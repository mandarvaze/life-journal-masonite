"""Migration for Entries Table."""
from orator.migrations import Migration


class CreateEntriesTable(Migration):
    """Migration Class for Entries Table."""

    def up(self):
        """Run the migrations."""
        with self.schema.create("entries") as table:
            table.increments("id")
            table.string("note")
            table.integer("rating")
            table.date("entry_for_date")

            table.integer("author_id").unsigned()
            table.foreign("author_id").references("id").on("users")

            table.timestamps()

    def down(self):
        """Revert the migrations."""
        self.schema.drop("entries")
