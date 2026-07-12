"""Trafilatura-based article extractor."""

import logging
from typing import Optional

import httpx

from .base import BaseExtractor
from ..models import TrafilaturaExtractorConfig

logger = logging.getLogger(__name__)


class TrafilaturaExtractor(BaseExtractor):
    def __init__(self, config: TrafilaturaExtractorConfig):
        self._config = config

    async def extract(self, url: str, client: httpx.AsyncClient) -> Optional[str]:
        try:
            import trafilatura
        except ImportError:
            logger.warning("trafilatura is not installed; install with: uv pip install trafilatura>=2.1.0")
            return None

        try:
            response = await client.get(url, follow_redirects=True)
            response.raise_for_status()
        except httpx.HTTPError as e:
            logger.warning("Failed to fetch article %s: %s", url, e)
            return None

        try:
            return trafilatura.extract(
                response.text,
                favor_precision=self._config.favor_precision,
                favor_recall=self._config.favor_recall,
            ) or None
        except Exception as e:
            logger.warning("trafilatura extraction failed for %s: %s", url, e)
            return None
