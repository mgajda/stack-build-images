FROM    ubuntu:rolling AS haskell-prep
RUN     apt-get update \
     && apt-get upgrade    -y \
     && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y software-properties-common \
                           curl wget jq \
                           pkg-config netbase git \
                           zlib1g-dev awscli make \
                           g++ gcc \
                           libc6-dev libffi-dev libgmp-dev \
                           xz-utils zlib1g-dev git gnupg \
                           libtinfo-dev \
                           alex happy \
                           libc6-pic apt-utils locales netbase \
                        --no-install-recommends \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists
ARG     LTS=15.3
#                           ruby ruby-bundler \
RUN     mkdir -p $HOME/.local/bin
ENV     SILENCE_ROOT_WARNING=1
ENV     DEBIAN_FRONTEND=noninteractive
#RUN     mkdir -p       /build/.bundle
#COPY    Dangerfile     /build/Dangerfile
#COPY    .bundle/config /build/.bundle/config
#COPY    Gemfile        /build/Gemfile
#COPY    Gemfile.lock   /build/Gemfile.lock
WORKDIR                /build
# Assortment of build tools
#COPY    pier           /usr/local/bin/pier
#COPY    cabal          /usr/local/bin/cabal
#RUN     bundle install --deployment
#RUN     curl -sSL https://get.haskellstack.org/ | sh
RUN     locale-gen en_SG.UTF-8 en_US.UTF-8
ENV     LC_ALL=en_SG.UTF-8
ENV     LANG=en_SG.UTF-8
RUN     curl -L https://github.com/commercialhaskell/stack/releases/download/v2.1.3/stack-2.1.3-linux-x86_64-static.tar.gz | tar xz --wildcards --strip-components=1 -C /usr/local/bin '*/stack'
COPY stack-${LTS}.yaml /root/.stack/global-project/stack.yaml
#RUN  echo "resolver: lts-${LTS}" >>/root/.stack/global-project/stack.yaml
RUN  stack install homplexity --haddock --test
RUN  stack install shake --haddock --test
RUN  stack install hlint
RUN  stack install hspec-discover --haddock --test
RUN  stack build aeson --haddock --test
RUN  stack build servant-client --haddock --test
RUN  stack build hspec --haddock --test
RUN  stack build HUnit --haddock --test
RUN  stack build QuickCheck --haddock --test
ENV  PATH=/root/.local/bin:/root/.cabal/bin:/opt/ghc/$GHC_VER/bin:/opt/cabal/$CABAL_VER/bin:$PATH
RUN  stack          --version
RUN  stack exec -- ghc   --version
RUN  stack exec -- hlint --version
RUN  stack exec -- homplexity-cli --version=True

