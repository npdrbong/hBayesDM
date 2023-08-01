import pytest

from hbayesdm.models import oms_ewmv


def test_oms_ewmv():
    _ = oms_ewmv(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
