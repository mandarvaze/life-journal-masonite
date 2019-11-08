"""Entry Model."""

from orator.orm import belongs_to

from config.database import Model


class Entry(Model):
    """Entry Model."""

    __fillable__ = ["note", "author_id", "rating"]

    @belongs_to("author_id", "id")
    def author(self):
        from app.User import User

        return User
