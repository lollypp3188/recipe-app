"""
Sample tests
"""
from contextlib import AbstractContextManager
from typing import Any
from django.test import SimpleTestCase
from app import calc


class CalcTests(SimpleTestCase):
  """Test the calc module."""

  def test_add_number(self):
    """Test adding number together."""
    res = calc.add(5,6)
    self.assertEqual(res, 11)


  def test_subtract_number(self):
    """Test subtracting numbers."""
    res = calc.subtract(10,15)
    self.assertEqual(res, 5)