import pytest

from hbayesdm.models import omsfree_ewmv


def test_omsfree_ewmv():
    _ = omsfree_ewmv(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
