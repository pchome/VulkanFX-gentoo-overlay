# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib

DESCRIPTION="A custom shader language called ReShade FX"
HOMEPAGE="https://github.com/crosire/reshade"
SRC_URI="https://github.com/crosire/reshade/archive/v${PV}.tar.gz -> reshade-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
IUSE="+glsl +hlsl +spirv"
REQUIRED_USE="|| ( glsl hlsl spirv )"
KEYWORDS="~amd64 ~x86"
RESTRICT="test"

DEPEND=">=dev-util/spirv-headers-1.2"
RDEPEND=""
BDEPEND="${DEPEND}
	spirv? ( dev-util/vma )"

S="${WORKDIR}/reshade-${PV}"

PATCHES=(
	"${FILESDIR}/vulkan_impl_type_convert-6.4.1.patch"
)

multilib_src_configure() {
	# Create meson.build file
	# meson init -n ReShadeFX --version 4.8.2 $(ls -1 source/effect_*.cpp | xargs)
	# meson rewrite target ReShadeFX rm_target
	# meson rewrite target --type shared_library ReShadeFX add_target $(ls -1 source/effect_*.cpp | xargs)
	cat > "${S}/meson.build" <<-EOF
	project('${PN}', ['cpp'], default_options : ['cpp_std=c++20'], version : '${PV}', meson_version : '>= 0.50')
	
	sources = [
	  'source/effect_expression.cpp',
	  'source/effect_lexer.cpp',
	  'source/effect_parser_exp.cpp',
	  'source/effect_parser_stmt.cpp',
	  'source/effect_preprocessor.cpp',
	  'source/effect_symbol_table.cpp',
	]
	
	headers = [
	  # ReShade FX
	  'source/effect_codegen.hpp',
	  'source/effect_expression.hpp',
	  'source/effect_lexer.hpp',
	  'source/effect_module.hpp',
	  'source/effect_parser.hpp',
	  'source/effect_preprocessor.hpp',
	  'source/effect_symbol_table.hpp',
	  'source/effect_token.hpp',
	
	  # ReShade API
	  'include/reshade_api.hpp',
	  'include/reshade_api_device.hpp',
	  'include/reshade_api_format.hpp',
	  'include/reshade_api_pipeline.hpp',
	  'include/reshade_api_resource.hpp',
	]
	
	headers_install_dir = 'reshade'
	
	# Shared lib
	out_lib = shared_library('ReShadeFX', sources, install: true)
	
	# pkgconfig
	pkg = import('pkgconfig')
	pkg.generate(out_lib, subdirs: headers_install_dir, description: '${DESCRIPTION}')
	EOF

	if use hlsl ; then
	cat >> "${S}/meson.build" <<-EOF
	# HLSL codegen
	sources_hlsl = [ 'source/effect_codegen_hlsl.cpp' ]
	out_lib_hlsl = shared_library('ReShadeFX-hlsl', sources_hlsl, link_with: [ out_lib ], install: true)
	pkg.generate(out_lib_hlsl, subdirs: headers_install_dir, description: '${DESCRIPTION} - HLSL')
	EOF
	fi

	if use glsl ; then
	cat >> "${S}/meson.build" <<-EOF
	# GLSL codegen
	sources_glsl = [ 'source/effect_codegen_glsl.cpp' ]
	out_lib_glsl = shared_library('ReShadeFX-glsl', sources_glsl, link_with: [ out_lib ], install: true)
	pkg.generate(out_lib_glsl, subdirs: headers_install_dir, description: '${DESCRIPTION} - GLSL')
	EOF
	fi

	if use spirv ; then
	cat >> "${S}/meson.build" <<-EOF
	headers += [
	  # Type converter
	  'source/vulkan/vulkan_impl_type_convert.hpp',
	]
	
	# SPIR-V codegen
	sources_spirv = [ 'source/effect_codegen_spirv.cpp' ]
	sources_type_convert = [ 'source/vulkan/vulkan_impl_type_convert.cpp' ]
	
	out_lib_spirv = shared_library('ReShadeFX-spirv', sources_spirv,
	  include_directories: [ '/usr/include/spirv/unified1' ],
	  link_with: [ out_lib ],
	  install: true)
	
	# Type cnovert
	out_lib_type_convert = shared_library('ReShadeFX-vulkan-type-convert', sources_type_convert,
	  cpp_args: ['-Wno-error=changes-meaning'],
	  include_directories: [ 'include', 'source/vulkan' ],
	  install: true)
	
	pkg.generate(out_lib_spirv, subdirs: headers_install_dir, description: '${DESCRIPTION} - SPIR-V')
	pkg.generate(out_lib_type_convert, subdirs: headers_install_dir, description: '${DESCRIPTION} - type converter')
	EOF
	fi

	cat >> "${S}/meson.build" <<-EOF
	# Headers
	install_headers(headers, subdir: headers_install_dir)
	EOF

	meson_src_configure
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc README.md REFERENCE.md
}
