import pytest

from hbayesdm.models import oms_par4


def test_oms_par4():
    _ = oms_par4(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
