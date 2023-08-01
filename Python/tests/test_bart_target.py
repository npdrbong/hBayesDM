import pytest

from hbayesdm.models import bart_target


def test_bart_target():
    _ = bart_target(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
