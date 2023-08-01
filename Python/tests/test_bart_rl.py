import pytest

from hbayesdm.models import bart_rl


def test_bart_rl():
    _ = bart_rl(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
