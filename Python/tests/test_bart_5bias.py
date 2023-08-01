import pytest

from hbayesdm.models import bart_5bias


def test_bart_5bias():
    _ = bart_5bias(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
