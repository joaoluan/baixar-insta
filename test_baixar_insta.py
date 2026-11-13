#!/usr/bin/env python3
import importlib.machinery
import importlib.util
import os
import unittest

SCRIPT_PATH = os.path.join(os.path.dirname(__file__), "baixar-insta")
loader = importlib.machinery.SourceFileLoader("baixar_insta", SCRIPT_PATH)
spec = importlib.util.spec_from_loader("baixar_insta", loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)


class TestBaixarInsta(unittest.TestCase):
    def test_profile_name(self):
        self.assertEqual(mod.profile_name("https://www.instagram.com/nasa/"), "nasa")
        self.assertEqual(mod.profile_name("https://instagram.com/joao.moura_1?igsh=123"), "joao.moura_1")
        self.assertIsNone(mod.profile_name("https://www.instagram.com/p/ABC123/"))
        self.assertIsNone(mod.profile_name("https://www.instagram.com/reel/XYZ789/"))
        self.assertIsNone(mod.profile_name("https://www.instagram.com/stories/nasa/"))

    def test_code_of(self):
        self.assertEqual(mod.code_of("/p/ABC123/"), "ABC123")
        self.assertEqual(mod.code_of("/nasa/reel/XYZ789"), "XYZ789")

    def test_find_media_and_urls(self):
        payload = {
            "data": [
                {
                    "code": "POST1",
                    "media_type": 1,
                    "image_versions2": {
                        "candidates": [
                            {"width": 640, "url": "https://cdn.example/small.jpg"},
                            {"width": 1080, "url": "https://cdn.example/large.jpg"},
                        ]
                    },
                },
                {
                    "code": "CAROUSEL1",
                    "media_type": 8,
                    "image_versions2": {"candidates": [{"width": 100, "url": "https://cdn.example/thumb.jpg"}]},
                    "carousel_media": [
                        {
                            "image_versions2": {"candidates": [{"width": 1080, "url": "https://cdn.example/1.jpg"}]},
                        },
                        {
                            "image_versions2": {"candidates": [{"width": 1080, "url": "https://cdn.example/2.jpg"}]},
                            "video_versions": [{"url": "https://cdn.example/2.mp4"}],
                        },
                    ],
                },
            ]
        }
        found = list(mod.find_media(payload))
        self.assertEqual(len(found), 2)
        self.assertEqual(mod.media_urls(found[0]), [("https://cdn.example/large.jpg", ".jpg")])
        self.assertEqual(
            mod.media_urls(found[1]),
            [("https://cdn.example/1.jpg", ".jpg"), ("https://cdn.example/2.mp4", ".mp4")],
        )

    def test_find_node(self):
        node = mod.find_node()
        self.assertTrue(isinstance(node, str) and len(node) > 0)

    def test_find_node_windows_mode(self):
        orig = mod.IS_WIN
        try:
            mod.IS_WIN = True
            node = mod.find_node()
            self.assertTrue(isinstance(node, str) and len(node) > 0)
        finally:
            mod.IS_WIN = orig


if __name__ == "__main__":
    unittest.main()
