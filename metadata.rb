name             'optsicom'
maintainer       'Patxi Gortázar'
maintainer_email 'patxi.gortazar@gmail.com'
license          'All rights reserved'
description      'Installs/Configures optsicom nodes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt', ">= 2.0.0"
depends 'jenkins', '~> 2.1.2'