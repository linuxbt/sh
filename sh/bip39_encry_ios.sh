#!/usr/bin/env bash
# ▼▼▼ 常量定义 ▼▼▼
huang='\033[33m'
hong='\033[31m'
lv='\033[32m'
bai='\033[0m'
kjlan='\033[96m'
hui='\e[37m'
lan='\033[0;34m'

# ▼▼▼ 配置项 ▼▼▼
ENCRYPTION_ALGO="aes-256-cbc"
OPENSSL_OPTS="-${ENCRYPTION_ALGO} -iter 1000000 -a -salt" # 改为100万次迭代提高iOS性能
MIN_PASSWORD_LENGTH=16

# ▼▼▼ 词表预处理函数 ▼▼▼
sanitize_wordlist() {
    # 移除BOM头、DOS换行符、尾部空行、前后空白字符
    echo "$BIP39_WORDLIST" | 
    sed -e '1s/^\xEF\xBB\xBF//' -e 's/\r$//' | # 移除BOM和CR
    awk 'NF {line=$0; print} END{if(NF) print line}' # 去空行保尾行
}

# ▼▼▼ BIP39词表（2048 words）▼▼▼
BIP39_WORDLIST=$(sanitize_wordlist <<'EOF'
abandon
ability
able
about
above
absent
absorb
abstract
absurd
abuse
access
accident
account
accuse
achieve
acid
acoustic
acquire
across
act
action
actor
actress
actual
adapt
add
addict
address
adjust
admit
adult
advance
advice
aerobic
affair
afford
afraid
again
age
agent
agree
ahead
aim
air
airport
aisle
alarm
album
alcohol
alert
alien
all
alley
allow
almost
alone
alpha
already
also
alter
always
amateur
amazing
among
amount
amused
analyst
anchor
ancient
anger
angle
angry
animal
ankle
announce
annual
another
answer
antenna
antique
anxiety
any
apart
apology
appear
apple
approve
april
arch
arctic
area
arena
argue
arm
armed
armor
army
around
arrange
arrest
arrive
arrow
art
artefact
artist
artwork
ask
aspect
assault
asset
assist
assume
asthma
athlete
atom
attack
attend
attitude
attract
auction
audit
august
aunt
author
auto
autumn
average
avocado
avoid
awake
aware
away
awesome
awful
awkward
axis
baby
bachelor
bacon
badge
bag
balance
balcony
ball
bamboo
banana
banner
bar
barely
bargain
barrel
base
basic
basket
battle
beach
bean
beauty
because
become
beef
before
begin
behave
behind
believe
below
belt
bench
benefit
best
betray
better
between
beyond
bicycle
bid
bike
bind
biology
bird
birth
bitter
black
blade
blame
blanket
blast
bleak
bless
blind
blood
blossom
blouse
blue
blur
blush
board
boat
body
boil
bomb
bone
bonus
book
boost
border
boring
borrow
boss
bottom
bounce
box
boy
bracket
brain
brand
brass
brave
bread
breeze
brick
bridge
brief
bright
bring
brisk
broccoli
broken
bronze
broom
brother
brown
brush
bubble
buddy
budget
buffalo
build
bulb
bulk
bullet
bundle
bunker
burden
burger
burst
bus
business
busy
butter
buyer
buzz
cabbage
cabin
cable
cactus
cage
cake
call
calm
camera
camp
can
canal
cancel
candy
cannon
canoe
canvas
canyon
capable
capital
captain
car
carbon
card
cargo
carpet
carry
cart
case
cash
casino
castle
casual
cat
catalog
catch
category
cattle
caught
cause
caution
cave
ceiling
celery
cement
census
century
cereal
certain
chair
chalk
champion
change
chaos
chapter
charge
chase
chat
cheap
check
cheese
chef
cherry
chest
chicken
chief
child
chimney
choice
choose
chronic
chuckle
chunk
churn
cigar
cinnamon
circle
citizen
city
civil
claim
clap
clarify
claw
clay
clean
clerk
clever
click
client
cliff
climb
clinic
clip
clock
clog
close
cloth
cloud
clown
club
clump
cluster
clutch
coach
coast
coconut
code
coffee
coil
coin
collect
color
column
combine
come
comfort
comic
common
company
concert
conduct
confirm
congress
connect
consider
control
convince
cook
cool
copper
copy
coral
core
corn
correct
cost
cotton
couch
country
couple
course
cousin
cover
coyote
crack
cradle
craft
cram
crane
crash
crater
crawl
crazy
cream
credit
creek
crew
cricket
crime
crisp
critic
crop
cross
crouch
crowd
crucial
cruel
cruise
crumble
crunch
crush
cry
crystal
cube
culture
cup
cupboard
curious
current
curtain
curve
cushion
custom
cute
cycle
dad
damage
damp
dance
danger
daring
dash
daughter
dawn
day
deal
debate
debris
decade
december
decide
decline
decorate
decrease
deer
defense
define
defy
degree
delay
deliver
demand
demise
denial
dentist
deny
depart
depend
deposit
depth
deputy
derive
describe
desert
design
desk
despair
destroy
detail
detect
develop
device
devote
diagram
dial
diamond
diary
dice
diesel
diet
differ
digital
dignity
dilemma
dinner
dinosaur
direct
dirt
disagree
discover
disease
dish
dismiss
disorder
display
distance
divert
divide
divorce
dizzy
doctor
document
dog
doll
dolphin
domain
donate
donkey
donor
door
dose
double
dove
draft
dragon
drama
drastic
draw
dream
dress
drift
drill
drink
drip
drive
drop
drum
dry
duck
dumb
dune
during
dust
dutch
duty
dwarf
dynamic
eager
eagle
early
earn
earth
easily
east
easy
echo
ecology
economy
edge
edit
educate
effort
egg
eight
either
elbow
elder
electric
elegant
element
elephant
elevator
elite
else
embark
embody
embrace
emerge
emotion
employ
empower
empty
enable
enact
end
endless
endorse
enemy
energy
enforce
engage
engine
enhance
enjoy
enlist
enough
enrich
enroll
ensure
enter
entire
entry
envelope
episode
equal
equip
era
erase
erode
erosion
error
erupt
escape
essay
essence
estate
eternal
ethics
evidence
evil
evoke
evolve
exact
example
excess
exchange
excite
exclude
excuse
execute
exercise
exhaust
exhibit
exile
exist
exit
exotic
expand
expect
expire
explain
expose
express
extend
extra
eye
eyebrow
fabric
face
faculty
fade
faint
faith
fall
false
fame
family
famous
fan
fancy
fantasy
farm
fashion
fat
fatal
father
fatigue
fault
favorite
feature
february
federal
fee
feed
feel
female
fence
festival
fetch
fever
few
fiber
fiction
field
figure
file
film
filter
final
find
fine
finger
finish
fire
firm
first
fiscal
fish
fit
fitness
fix
flag
flame
flash
flat
flavor
flee
flight
flip
float
flock
floor
flower
fluid
flush
fly
foam
focus
fog
foil
fold
follow
food
foot
force
forest
forget
fork
fortune
forum
forward
fossil
foster
found
fox
fragile
frame
frequent
fresh
friend
fringe
frog
front
frost
frown
frozen
fruit
fuel
fun
funny
furnace
fury
future
gadget
gain
galaxy
gallery
game
gap
garage
garbage
garden
garlic
garment
gas
gasp
gate
gather
gauge
gaze
general
genius
genre
gentle
genuine
gesture
ghost
giant
gift
giggle
ginger
giraffe
girl
give
glad
glance
glare
glass
glide
glimpse
globe
gloom
glory
glove
glow
glue
goat
goddess
gold
good
goose
gorilla
gospel
gossip
govern
gown
grab
grace
grain
grant
grape
grass
gravity
great
green
grid
grief
grit
grocery
group
grow
grunt
guard
guess
guide
guilt
guitar
gun
gym
habit
hair
half
hammer
hamster
hand
happy
harbor
hard
harsh
harvest
hat
have
hawk
hazard
head
health
heart
heavy
hedgehog
height
hello
helmet
help
hen
hero
hidden
high
hill
hint
hip
hire
history
hobby
hockey
hold
hole
holiday
hollow
home
honey
hood
hope
horn
horror
horse
hospital
host
hotel
hour
hover
hub
huge
human
humble
humor
hundred
hungry
hunt
hurdle
hurry
hurt
husband
hybrid
ice
icon
idea
identify
idle
ignore
ill
illegal
illness
image
imitate
immense
immune
impact
impose
improve
impulse
inch
include
income
increase
index
indicate
indoor
industry
infant
inflict
inform
inhale
inherit
initial
inject
injury
inmate
inner
innocent
input
inquiry
insane
insect
inside
inspire
install
intact
interest
into
invest
invite
involve
iron
island
isolate
issue
item
ivory
jacket
jaguar
jar
jazz
jealous
jeans
jelly
jewel
job
join
joke
journey
joy
judge
juice
jump
jungle
junior
junk
just
kangaroo
keen
keep
ketchup
key
kick
kid
kidney
kind
kingdom
kiss
kit
kitchen
kite
kitten
kiwi
knee
knife
knock
know
lab
label
labor
ladder
lady
lake
lamp
language
laptop
large
later
latin
laugh
laundry
lava
law
lawn
lawsuit
layer
lazy
leader
leaf
learn
leave
lecture
left
leg
legal
legend
leisure
lemon
lend
length
lens
leopard
lesson
letter
level
liar
liberty
library
license
life
lift
light
like
limb
limit
link
lion
liquid
list
little
live
lizard
load
loan
lobster
local
lock
logic
lonely
long
loop
lottery
loud
lounge
love
loyal
lucky
luggage
lumber
lunar
lunch
luxury
lyrics
machine
mad
magic
magnet
maid
mail
main
major
make
mammal
man
manage
mandate
mango
mansion
manual
maple
marble
march
margin
marine
market
marriage
mask
mass
master
match
material
math
matrix
matter
maximum
maze
meadow
mean
measure
meat
mechanic
medal
media
melody
melt
member
memory
mention
menu
mercy
merge
merit
merry
mesh
message
metal
method
middle
midnight
milk
million
mimic
mind
minimum
minor
minute
miracle
mirror
misery
miss
mistake
mix
mixed
mixture
mobile
model
modify
mom
moment
monitor
monkey
monster
month
moon
moral
more
morning
mosquito
mother
motion
motor
mountain
mouse
move
movie
much
muffin
mule
multiply
muscle
museum
mushroom
music
must
mutual
myself
mystery
myth
naive
name
napkin
narrow
nasty
nation
nature
near
neck
need
negative
neglect
neither
nephew
nerve
nest
net
network
neutral
never
news
next
nice
night
noble
noise
nominee
noodle
normal
north
nose
notable
note
nothing
notice
novel
now
nuclear
number
nurse
nut
oak
obey
object
oblige
obscure
observe
obtain
obvious
occur
ocean
october
odor
off
offer
office
often
oil
okay
old
olive
olympic
omit
once
one
onion
online
only
open
opera
opinion
oppose
option
orange
orbit
orchard
order
ordinary
organ
orient
original
orphan
ostrich
other
outdoor
outer
output
outside
oval
oven
over
own
owner
oxygen
oyster
ozone
pact
paddle
page
pair
palace
palm
panda
panel
panic
panther
paper
parade
parent
park
parrot
party
pass
patch
path
patient
patrol
pattern
pause
pave
payment
peace
peanut
pear
peasant
pelican
pen
penalty
pencil
people
pepper
perfect
permit
person
pet
phone
photo
phrase
physical
piano
picnic
picture
piece
pig
pigeon
pill
pilot
pink
pioneer
pipe
pistol
pitch
pizza
place
planet
plastic
plate
play
please
pledge
pluck
plug
plunge
poem
poet
point
polar
pole
police
pond
pony
pool
popular
portion
position
possible
post
potato
pottery
poverty
powder
power
practice
praise
predict
prefer
prepare
present
pretty
prevent
price
pride
primary
print
priority
prison
private
prize
problem
process
produce
profit
program
project
promote
proof
property
prosper
protect
proud
provide
public
pudding
pull
pulp
pulse
pumpkin
punch
pupil
puppy
purchase
purity
purpose
purse
push
put
puzzle
pyramid
quality
quantum
quarter
question
quick
quit
quiz
quote
rabbit
raccoon
race
rack
radar
radio
rail
rain
raise
rally
ramp
ranch
random
range
rapid
rare
rate
rather
raven
raw
razor
ready
real
reason
rebel
rebuild
recall
receive
recipe
record
recycle
reduce
reflect
reform
refuse
region
regret
regular
reject
relax
release
relief
rely
remain
remember
remind
remove
render
renew
rent
reopen
repair
repeat
replace
report
require
rescue
resemble
resist
resource
response
result
retire
retreat
return
reunion
reveal
review
reward
rhythm
rib
ribbon
rice
rich
ride
ridge
rifle
right
rigid
ring
riot
ripple
risk
ritual
rival
river
road
roast
robot
robust
rocket
romance
roof
rookie
room
rose
rotate
rough
round
route
royal
rubber
rude
rug
rule
run
runway
rural
sad
saddle
sadness
safe
sail
salad
salmon
salon
salt
salute
same
sample
sand
satisfy
satoshi
sauce
sausage
save
say
scale
scan
scare
scatter
scene
scheme
school
science
scissors
scorpion
scout
scrap
screen
script
scrub
sea
search
season
seat
second
secret
section
security
seed
seek
segment
select
sell
seminar
senior
sense
sentence
series
service
session
settle
setup
seven
shadow
shaft
shallow
share
shed
shell
sheriff
shield
shift
shine
ship
shiver
shock
shoe
shoot
shop
short
shoulder
shove
shrimp
shrug
shuffle
shy
sibling
sick
side
siege
sight
sign
silent
silk
silly
silver
similar
simple
since
sing
siren
sister
situate
six
size
skate
sketch
ski
skill
skin
skirt
skull
slab
slam
sleep
slender
slice
slide
slight
slim
slogan
slot
slow
slush
small
smart
smile
smoke
smooth
snack
snake
snap
sniff
snow
soap
soccer
social
sock
soda
soft
solar
soldier
solid
solution
solve
someone
song
soon
sorry
sort
soul
sound
soup
source
south
space
spare
spatial
spawn
speak
special
speed
spell
spend
sphere
spice
spider
spike
spin
spirit
split
spoil
sponsor
spoon
sport
spot
spray
spread
spring
spy
square
squeeze
squirrel
stable
stadium
staff
stage
stairs
stamp
stand
start
state
stay
steak
steel
stem
step
stereo
stick
still
sting
stock
stomach
stone
stool
story
stove
strategy
street
strike
strong
struggle
student
stuff
stumble
style
subject
submit
subway
success
such
sudden
suffer
sugar
suggest
suit
summer
sun
sunny
sunset
super
supply
supreme
sure
surface
surge
surprise
surround
survey
suspect
sustain
swallow
swamp
swap
swarm
swear
sweet
swift
swim
swing
switch
sword
symbol
symptom
syrup
system
table
tackle
tag
tail
talent
talk
tank
tape
target
task
taste
tattoo
taxi
teach
team
tell
ten
tenant
tennis
tent
term
test
text
thank
that
theme
then
theory
there
they
thing
this
thought
three
thrive
throw
thumb
thunder
ticket
tide
tiger
tilt
timber
time
tiny
tip
tired
tissue
title
toast
tobacco
today
toddler
toe
together
toilet
token
tomato
tomorrow
tone
tongue
tonight
tool
tooth
top
topic
topple
torch
tornado
tortoise
toss
total
tourist
toward
tower
town
toy
track
trade
traffic
tragic
train
transfer
trap
trash
travel
tray
treat
tree
trend
trial
tribe
trick
trigger
trim
trip
trophy
trouble
truck
true
truly
trumpet
trust
truth
try
tube
tuition
tumble
tuna
tunnel
turkey
turn
turtle
twelve
twenty
twice
twin
twist
two
type
typical
ugly
umbrella
unable
unaware
uncle
uncover
under
undo
unfair
unfold
unhappy
uniform
unique
unit
universe
unknown
unlock
until
unusual
unveil
update
upgrade
uphold
upon
upper
upset
urban
urge
usage
use
used
useful
useless
usual
utility
vacant
vacuum
vague
valid
valley
valve
van
vanish
vapor
various
vast
vault
vehicle
velvet
vendor
venture
venue
verb
verify
version
very
vessel
veteran
viable
vibrant
vicious
victory
video
view
village
vintage
violin
virtual
virus
visa
visit
visual
vital
vivid
vocal
voice
void
volcano
volume
vote
voyage
wage
wagon
wait
walk
wall
walnut
want
warfare
warm
warrior
wash
wasp
waste
water
wave
way
wealth
weapon
wear
weasel
weather
web
wedding
weekend
weird
welcome
west
wet
whale
what
wheat
wheel
when
where
whip
whisper
wide
width
wife
wild
will
win
window
wine
wing
wink
winner
winter
wire
wisdom
wise
wish
witness
wolf
woman
wonder
wood
wool
word
work
world
worry
worth
wrap
wreck
wrestle
wrist
write
wrong
yard
year
yellow
you
young
youth
zebra
zero
zone
zoo
EOF
)

# ▼▼▼ 校验系统（增强版）▼▼▼
validate_wordlist() {
    echo -e "\n=== 词表诊断 ==="
    echo "首词：$(echo "$BIP39_WORDLIST" | head -1 | od -An -tx1 | tr -d ' ')"
    echo "尾词：$(echo "$BIP39_WORDLIST" | tail -1 | od -An -tx1 | tr -d ' ')"
    echo -n "行尾符："
    if echo "$BIP39_WORDLIST" | head -1 | grep -q $'\r'; then 
        echo "CRLF"
    else
        echo "LF"
    fi
    echo "实际行数：$(echo "$BIP39_WORDLIST" | wc -l)"
    
    local calculated_hash=$(echo "$BIP39_WORDLIST" | sha256sum | cut -d' ' -f1)
    local expected_hash="a4f33376d79e6b1bf8a7a8e114f3d3f0571f3ef1acb6e67c97b94f622272b73"
    
    if [ "$calculated_hash" != "$expected_hash" ]; then
        echo -e "\n${hong}⚠️ 校验失败！差异分析：${bai}"
        diff <(echo "$BIP39_WORDLIST") <(curl -s https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt) | head -10
        return 1
    fi
    return 0
}
# ▼▼▼ 主流程 ▼▼▼
if ! validate_wordlist; then
    echo -e "${hong}错误：词表校验未通过，请检查："
    echo "1. 是否有多余空行"
    echo "2. 是否包含不可见字符"
    echo "3. 是否完整包含2048个单词"
    echo -e "${bai}建议操作："
    echo "curl -O https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt"
    echo "mv english.txt bip39_wordlist.txt && chmod 600 bip39_wordlist.txt"
    exit 1
fi
    

# ▼▼▼ 兼容性调试函数 ▼▼▼
debug_light() {
    echo -e "\n=== 词表校验 ==="
    echo "行数: $(echo "$BIP39_WORDLIST" | wc -l)/2048"
    echo "首词: $(echo "$BIP39_WORDLIST" | head -1 | od -An -tx1)"
    echo "尾词: $(echo "$BIP39_WORDLIST" | tail -1 | od -An -tx1)"
    echo -n "行尾符: "
    echo "$BIP39_WORDLIST" | head -1 | grep -q $'\r' && echo "CRLF" || echo "LF"
}

validate_busybox() {
    local hash=$(echo "$BIP39_WORDLIST" | sha256sum | cut -d' ' -f1)
    [[ "$hash" == "a4f33376d79e6b1bf8a7a8e114f3d3f0571f3ef1acb6e67c97b94f622272b73" ]] || {
        echo -e "${hong}校验失败! 原因可能是:${bai}"
        echo "1. 词表被修改"
        echo "2. 存在隐藏字符(BOM/CRLF)"
        return 1
    }
}

# ▼▼▼ 主逻辑前置检查 ▼▼▼
if ! validate_busybox; then
    debug_light
    echo -e "${hong}致命错误：BIP39词表验证失败${bai}" >&2
    exit 1
fi

# ▼▼▼ Python助记词生成脚本 ▼▼▼
read -r -d '' PYTHON_MNEMONIC_GENERATOR_SCRIPT << 'EOF_PYTHON_SCRIPT'
#!/usr/bin/env python3
import sys, os, hashlib
wordlist = [w.strip() for w in sys.stdin if w.strip()]
if len(wordlist) != 2048:
    print(f"错误：需要2048个单词，实际获取{len(wordlist)}个", file=sys.stderr)
    sys.exit(1)
# ... (后续Python代码保持原样不变)
try:
    word_count = int(sys.argv[1])
except ValueError:
    print(f"Error: Invalid word count argument '{sys.argv[1]}'. Must be an integer.", file=sys.stderr)
    sys.exit(1)

# Determine entropy and checksum lengths based on word count
# BIP39 standard: Entropy length (bits) | Checksum length (bits) | Mnemonic length (words)
# 128 | 4 | 12
# 192 | 6 | 18
# 256 | 8 | 24
entropy_bytes_length = 0
checksum_bits_length = 0
total_bits_length = 0 # Total bits = entropy + checksum

if word_count == 12:
    entropy_bytes_length = 16 # 128 bits
    checksum_bits_length = 4
    total_bits_length = 132 # 128 + 4
elif word_count == 18:
    entropy_bytes_length = 24 # 192 bits
    checksum_bits_length = 6
    total_bits_length = 198 # 192 + 6
elif word_count == 24:
    entropy_bytes_length = 32 # 256 bits
    checksum_bits_length = 8
    total_bits_length = 264 # 256 + 8
else:
    print(f"Error: Invalid word count '{word_count}'. Must be 12, 18, or 24.", file=sys.stderr)
    sys.exit(1)

# Expected total bits must be word_count * 11
if total_bits_length != word_count * 11:
     print(f"Internal Error: Mismatch between word count ({word_count}) and calculated total bits ({total_bits_length}).", file=sys.stderr)
     sys.exit(1)

try:
    # Generate entropy using a secure source
    entropy_bytes = os.urandom(entropy_bytes_length)

    # Calculate checksum (first checksum_bits_length from SHA256 hash of entropy)
    checksum_full_bytes = hashlib.sha256(entropy_bytes).digest()
    # Extract the required number of checksum bits
    # Need to convert bytes to an integer and shift/mask
    checksum_int = int.from_bytes(checksum_full_bytes, 'big')

    # The first `checksum_bits_length` bits of the hash are the checksum.
    # The SHA256 hash is 256 bits. We want the top bits.
    # Shift right by 256 - checksum_bits_length to move the desired bits to the LSB position.
    # Mask with (1 << checksum_bits_length) - 1 to keep only those bits.
    checksum_value = (checksum_int >> (256 - checksum_bits_length)) & ((1 << checksum_bits_length) - 1)


    # Combine entropy and checksum bits
    # Convert entropy bytes to a large integer
    entropy_int = int.from_bytes(entropy_bytes, 'big')

    # The combined integer has total_bits_length bits.
    # The bits are arranged as [entropy][checksum] from MSB to LSB.
    # To combine, shift the entropy bits left by the number of checksum bits, then OR with the checksum value.
    combined_int = (entropy_int << checksum_bits_length) | checksum_value

    # Extract 11-bit chunks
    mnemonic_words = []

    # The k-th word index (0-indexed) comes from bits [k*11] to [(k+1)*11 - 1] (MSB is bit 0)
    # In terms of shifting from LSB (bit 0): shift right by (total_bits_length - (k+1)*11) and mask
    for i in range(word_count):
        # Extract the i-th 11-bit chunk from the left (MSB)
        # The index of the 11-bit chunk from LSB is total_bits_length - (i+1)*11
        shift = total_bits_length - (i + 1) * 11
        word_index = (combined_int >> shift) & 0x7FF # 0x7FF is 11 bits set to 1

        if word_index >= len(wordlist):
             # Should not happen with correct bit manipulation and wordlist size
             print(f"Internal Error: Calculated word index {word_index} is out of bounds (wordlist size {len(wordlist)}).", file=sys.stderr)
             sys.exit(1)
        mnemonic_words.append(wordlist[word_index])

    # Print the mnemonic separated by spaces
    print(' '.join(mnemonic_words))
    sys.stdout.flush()

except ImportError as e:
    print(f"Error: Missing standard Python module: {e}. Ensure your Python installation is complete.", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error during mnemonic generation: {e}", file=sys.stderr)
    sys.exit(1)

EOF_PYTHON_SCRIPT

# ▼▼▼ 临时文件处理 ▼▼▼
create_python_script_temp_file() {
    USER_TMP_DIR="${HOME}/.mnemonic_temp"
    mkdir -p "$USER_TMP_DIR" || { 
        echo "无法创建临时目录 ${USER_TMP_DIR}" >&2
        exit 1
    }
    PYTHON_SCRIPT_TEMP_FILE="${USER_TMP_DIR}/mnemonic_$(date +%s%N).py"
    printf "%s" "$PYTHON_MNEMONIC_GENERATOR_SCRIPT" > "$PYTHON_SCRIPT_TEMP_FILE" || {
        echo "无法写入Python脚本" >&2
        exit 1
    }
    trap 'rm -f "$PYTHON_SCRIPT_TEMP_FILE"' EXIT
}

# ▼▼▼ 依赖检查 ▼▼▼
check_dependencies() {
    for cmd in openssl python3; do
        if ! command -v $cmd &>/dev/null; then
            echo -e "${huang}正在尝试安装 $cmd...${bai}"
            if ! sudo apk add $cmd >/dev/null 2>&1; then
                echo -e "${hong}错误：无法安装 $cmd${bai}" >&2
                exit 1
            fi
        fi
    done
}

# ▼▼▼ 密码输入函数 ▼▼▼
get_password() {
    local password=""
    while : ; do
        read -rsp "$1 (最少$MIN_PASSWORD_LENGTH位): " password
        echo
        if [[ ${#password} -lt $MIN_PASSWORD_LENGTH ]]; then
            echo -e "${huang}密码必须至少$MIN_PASSWORD_LENGTH个字符${bai}" >&2
        else
            break
        fi
    done
    echo "$password"
}

# ▼▼▼ 助记词生成加密流程 ▼▼▼
generate_and_encrypt() {
    local word_count="$1"
    local mnemonic=$(echo "$BIP39_WORDLIST" | python3 "$PYTHON_SCRIPT_TEMP_FILE" "$word_count") || {
        echo -e "${hong}助记词生成失败${bai}" >&2
        exit 1
    }

    echo -e "${lv}✔ ${word_count}位助记词已生成${bai}"
    local password=$(get_password "设置加密密码")
    
    echo -e "${huang}加密中... (约20秒)${bai}"
    local encrypted=$(echo "$mnemonic" | openssl enc $OPENSSL_OPTS -pass stdin <<<"$password")
    
    echo -e "\n${kjlan}======= 加密结果 =======${bai}"
    echo "$encrypted"
    echo -e "${kjlan}=======================${bai}"
    echo -e "${huang}⚠️ 请立即将上方加密字符串和密码分开保存！${bai}"
}

# ▼▼▼ 解密流程 ▼▼▼
decrypt_mnemonic() {
    echo -e "${hong}请粘贴加密字符串（以空行结束）：${bai}"
    local encrypted=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        encrypted+="$line"$'\n'
    done
    encrypted="${encrypted%$'\n'}"
    
    local password=$(get_password "输入解密密码")
    echo -e "${huang}解密中...${bai}"
    
    local decrypted=$(echo "$encrypted" | openssl enc -d $OPENSSL_OPTS -pass stdin <<<"$password") || {
        echo -e "${hong}解密失败！密码或密文错误${bai}" >&2
        exit 1
    }
    
    echo -e "\n${lv}======= 助记词 =======${bai}"
    echo "$decrypted"
    echo -e "${lv}=====================${bai}"
    read -n 1 -s -r -p "按任意键清除屏幕..."
    clear
}

# ▼▼▼ 主菜单 ▼▼▼
main_menu() {
    while : ; do
        clear
        echo -e "${kjlan}┌───────────────────────┐"
        echo -e "│ BIP39 助记词管理器    │"
        echo -e "├───────────────────────┤"
        echo -e "│ 1. 生成并加密助记词   │"
        echo -e "│ 2. 解密助记词         │"
        echo -e "│ q. 退出               │"
        echo -e "└───────────────────────┘${bai}"
        read -p "选择: " choice
        
        case "$choice" in
            1)  
                clear
                echo -e "${lan}选择助记词长度:"
                echo "1. 12单词 | 2. 18单词 | 3. 24单词"
                read -p "选项: " len
                case "$len" in
                    1) generate_and_encrypt 12 ;;
                    2) generate_and_encrypt 18 ;;
                    3) generate_and_encrypt 24 ;;
                    *) echo -e "${huang}无效选择${bai}"; sleep 1 ;;
                esac
                ;;
            2)  decrypt_mnemonic ;;
            q)  exit 0 ;;
            *)  echo -e "${huang}无效输入${bai}"; sleep 1 ;;
        esac
        read -n 1 -s -r -p "按任意键继续..."
    done
}

# ▼▼▼ 执行入口 ▼▼▼
create_python_script_temp_file
check_dependencies
main_menu
