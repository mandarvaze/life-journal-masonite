"""Entry Model."""

from orator.orm import belongs_to

from config.database import Model


class Entry(Model):
    """Entry Model."""

    __fillable__ = ["note", "rating", "entry_for_date", "author_id"]

    @belongs_to("author_id", "id")
    def author(self):
        from app.User import User

        return User
