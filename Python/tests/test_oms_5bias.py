import pytest

from hbayesdm.models import oms_5bias


def test_oms_5bias():
    _ = oms_5bias(
        data="example", niter=10, nwarmup=5, nchain=1, ncore=1)


if __name__ == '__main__':
    pytest.main()
