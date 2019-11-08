"""A EntryController Module."""

from masonite.controllers import Controller
from masonite.request import Request
from masonite.view import View


class EntryController(Controller):
    """EntryController Controller Class."""

    def __init__(self, request: Request):
        """EntryController Initializer

        Arguments:
            request {masonite.request.Request} -- The Masonite Request class.
        """
        self.request = request

    def show(self, view: View):
        entries = [
            {"rating": 2, "note": "Masonite Sample worked!!"},
            {"rating": 0, "note": "Just a regular day"},
        ]
        return view.render("entries", {"entries": entries})
