"""A EntryController Module."""
from datetime import datetime

from masonite.controllers import Controller
from masonite.request import Request
from masonite.view import View

from app.Entry import Entry


class EntryController(Controller):
    """EntryController Controller Class."""

    def __init__(self, request: Request):
        """EntryController Initializer

        Arguments:
            request {masonite.request.Request} -- The Masonite Request class.
        """
        self.request = request

    def show(self, view: View):
        entries = (
            Entry.where("author_id", "=", self.request.user().id)
            .get()
            .sort(lambda entry: entry.entry_for_date)
        )
        return view.render("entries", {"entries": entries})

    def store(self, request: Request):
        Entry.create(
            note=request.input("note"),
            rating=request.input("rating"),
            author_id=request.user().id,
            entry_for_date=datetime.today().strftime("%Y-%m-%d"),
        )

        request.session.flash("success", "Entry Added Successfully!")
        return request.redirect("/home")

    def create(self, view: View):
        """Show the input form."""
        return view.render("entry")
