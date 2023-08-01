import pytest

from hbayesdm.models import omsfree_5bias


def test_omsfree_5bias():
    _ = omsfree_5bias(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
