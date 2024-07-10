#>>> help(session_info.main.show)
# could not get versions for:
# cython_runtime              NA
# mpl_toolkits                NA
#sitecustomize               NA
#xalt_python_pkg_filter      NA
#zoneinfo                    NA
#
#>>> session_info.main.show(dependencies=True)
#-----
vvec = c(
"accelerate==0.21.0",
"datasets==2.20.0",
"session_info==1.0.0",
"aiohttp==3.9.5",
"aiosignal==1.3.1",
"anndata==0.10.8",
"async_timeout==4.0.3",
"attr==0.3.2",
"brotli==1.1.0",
"certifi==2024.06.02",
"cffi==1.16.0",
"charset_normalizer==3.3.2",
"colorama==0.4.6",
"python-dateutil==2.9.0",
"dill==0.3.8",
"exceptiongroup==1.2.0",
"filelock==3.15.4",
"frozenlist==1.4.1",
"fsspec==2024.5.0",
"h5py==3.11.0",
"huggingface_hub==0.23.4",
"idna==3.7",
"llvmlite==0.42.0",
"loompy==3.0.7",
"mpmath==1.3.0",
"multidict==6.0.5",
"multiprocess==0.70.16",
"natsort==8.4.0",
"numba==0.59.1",
"numpy==1.26.4",
"numpy_groupies==0.11.1",
"packaging==24.1",
"pandas==2.2.2",
"pyarrow==16.1.0",
"pyarrow_hotfix==0.6",
"pycparser==2.22",
"pydot==2.0.0",
"pyparsing==3.1.2",
"pytz==2024.1",
"requests==2.32.3",
"scipy==1.13.1",
"six==1.16.0",
"python-socks==2.5.0",
"safetensors==0.4.2",
"scanpy==1.10.2",
"seaborn==0.13.2",
"sympy==1.12.1",
"tdigest==0.5.2.2",
"threadpoolctl==3.5.0",
"torch==2.0.1",
"torchgen==0.0.1",
"tqdm==4.66.4",
"transformers==4.28.1",
"typing_extensions==4.12.2",
"urllib3==2.2.2",
"xxhash==3.4.1",
"pyyaml==6.0.1",
"yarl==1.9.4")

gfenv = basilisk::BasiliskEnvironment(
  envname='gfenv',
  pkgname="BiocGF",
  packages = "python==3.10.14",
  pip = vvec)
#-----
#Python==3.10.14 | packaged by conda-forge | (main, Mar 20 2024, 12:45:18) [GCC 12.3.0]
#Linux-6.5.0-41-generic-x86_64-with-glibc2.35
#-----
#Session==information updated at 2024-07-03 09:50

#==https://pytorch.org/get-started/previous-versions/ for cu121 on torch
