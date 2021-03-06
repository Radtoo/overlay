# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} )
WX_GTK_VER="3.0"

inherit distutils-r1 wxwidgets

P_HASH="7c3ced03c3c76b9f98e4a0edae1801755a7599ebf481c04d9f77dfff17e3"
MY_PN="wxPython"

DESCRIPTION="A blending of the wxWindows C++ class library with Python"
HOMEPAGE="http://www.wxpython.org/"
SRC_URI="https://files.pythonhosted.org/packages/17/74/${P_HASH}/${MY_PN}-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="wxWinLL-3"
SLOT="3.0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	dev-python/appdirs[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	$(python_gen_cond_dep 'dev-python/pypubsub:3[${PYTHON_USEDEP}]' -2 )
	$(python_gen_cond_dep 'dev-python/pypubsub:4[${PYTHON_USEDEP}]' -3 )
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
	dev-python/twine[${PYTHON_USEDEP}]
	dev-python/wheel[${PYTHON_USEDEP}]
"

DEPEND="
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}/${PN}"-4.0.3-webkit.patch
	"${FILESDIR}/${PN}"-4.0.3-parallel.patch
)

S="${WORKDIR}/${MY_PN}-${PV}"

python_prepare_all() {
	if use test; then
		# Errors reported upstream: https://github.com/wxWidgets/Phoenix/issues/1025
		sed -i \
			-e "/class GetAutoCompleteListTestCase(GetAttributeTestCase):/i@unittest.skip('Known to fail')" \
			-e "/class GetAttributeNamesTestCase(GetAttributeTestCase):/i@unittest.skip('Known to fail')" \
			wx/py/tests/test_introspect.py || die
	fi
	distutils-r1_python_prepare_all
}

python_test() {
	distutils-r1_install_for_testing
	cd "${BUILD_DIR}/lib/wx/py/tests" || die
	${EPYTHON} -m unittest discover || die
}
