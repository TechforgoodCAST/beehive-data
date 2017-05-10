
# Regexes
BEN_REGEXES = {
  :crime => /\b(crim(inal|e)|justice|judicial|offenders?|custody|anti-social behaviour|prison(ers?)?|law centre|victim|murder|rape|theft|fraud)\b/i, # possible confusion with "social justice" and "restorative justice",
  :relationship => /\b(relationship|marriage|family breakdown|mediation|counselling|conflict resolution)\b/i, # relationship a bit general
  :disabilities => /\b(disabled|disabilit(ies|y)|blind(ness)?|deaf(ness)?|(hearing|sight) loss|amputee|wheel ?\-?chair|accessib(ility|le)|handicap(ped)?|less abled|sign language|impairment|visual(ly)? ?\-?impair(ment|ed)|special needs|hearing loop)\b/i,
  :religion => /\b(christ(ian)?|muslim|jew(ish)|mosque|synagogue|church|buddhis(t|m)|sikh)\b/i, # bit wide, need to exclude, eg church halls
  :disasters => /\b(flood(s|ing)?|disasters?|rescue|survivors?|tsunami|storms?|hurricane|aftermath)\b/i, # need a wider range "survivors" has DV use too, rescue used a lot for animals
  :education => /\b(schools?|pupils?|students?|school\-?age|teach(ers?|ing)|college|a ?\-?levels?|g\.?c\.?s\.?e\.?s?|key stage (1|2|3|one|two|three)|mentoring|educational|school(child|boy|girl)(ren|s)?|classroom|university|learning|training|skills|essay writing|U3A|provision of books)\b/i, # need to exclude pre-school? schools are a venue for lots of activities
  :unemployed => /\b((un)?-?employ(ed|ment)|job-?seekers?|benefit claimants?|claim benefits|jobless|out of work|career|employability)\b/i,
  :ethnic => /\b(b\.?a?m\.?e\.?|black|ethnic|racial|roma|multi\-?cultural)\b/i, # black may be too generic?
  :water => /\b(water|sanitation|toilets?|sewage|hygien(e|ic)|wastewater)\b/i, # need to exclude water sports
  :food => /\b(food|hunger|feed|local produce|food\-?bank|fruits?|vegetables?|cook(ery|ing)|famines?|(mal)?nutrition(ist)?|meat|healthy eating )\b/i,
  :housing => /\b(housing|homeless(ness)?|tenants?|rough ?\-?sleep(ing|ers?)|runaways?|residents?|household|shelter)\b/i, # housing is a verb, and is generic
  :animals => /\b(animals?|pets?|dogs?|cats?|horses?|wildlife|fauna|farm-animal|livestock|marine|habitat|birds?|show\-? ?jumping)\b/i,
  :buildings => /\b((community|new|existing) building|built environment|architecture|refurbish(ing|ment)?|repairs?|restoration|(community|village) hall|Preservation Trust|Building works)\b/i, # building and heritage both a bit too wide
  :mental => /\b(mental ?\-?(health|illness(es)?|diseases?|disorders?)|depressian|schizophrenia|bi\-?polar|psychiatry|psychiatric|eating ?-?disorders?|Self ?\-?help|anxiety|self\-? ?harm)\b/i, # mental disease could cover dementia/learning disabilities
  :orientation => /\b(l\.?g\.?b\.?t?\.?q?\.?|lesbian|gay|bi\-?sexual|sexuality|sexual orientation|trans\-?(sexual|gender)?|homo\-?sexual|queer|cisgender|intersex|single sex parents)\b/i, # rainbow - but children too
  :environment => /\b(environment(al)?|climat(e|ic)|global warming|carbon|energy efficien(t|cy)|ecosystem|nature|green spaces?|bio\-?diversity|sustainab(ility|le)|countryside|garden(ing)?|pond|parks?|eco\-?audit|footpaths?|wilderness|greenhouse gas|ecolog(y|ical)|recycl(ed|ing)|trees?|allotment|community land trust|(fuel|energy) ?\-?saving|farmland|horticultur(e|al)|litter)\b/i, # environment a bti broad: learning environment, peaceful environment, etc
  :physical => /\b(physical health|cancer|disease|illness|Down\'?s Syndrome|get fit|fitness|sport(ing|s)?|physiotherapy|Multiple Sclerosis|stroke|diabetes|Healthy (Living|lifestyle|activity)|health ?care|blood pressure|virus|infection|gym|dancing|walking|active|over\-?weight|fibromyalgia)\b/i, # exclude mental? often says "physical and mental health"
  :organisation => /\b((this|our) organisation|core (costs|funding)|Business Plan|IT Equipment)\b/i, # not sure about this one!
  :organisations => /\b(charities|local groups|community groups|social enterprises|Council for Voluntary Service|VCS|community cent(er|re)|community organisations)\b/i,
  :poverty => /\b(poverty|deprivation|isolat(ed|ion)|disadvantaged)\b/i, # "poor" is too generic, used as an adjective
  :refugees => /\b(asylum ?-?seekers?|refugees?|migrants?|displaced persons?)\b/i, # sanctuary?
  :services => /\b(armed forces|army|navy|air force|marines|armed services|(ex\-)?servicem(e|a)n\'?s?|veterans?|british legion|regiment(al)?|military|sailors?|soldiers?|cadets)\b/i,
  :care => /\b(care ?\-?leavers?|leaving care|looked ?\-?after ?\-?(children)?|carers?|leave care)\b/i, # definition of care here?
  :exploitation => /\b((sex)? ?\-?traffic(k?ing)?|exploitation|forced labour|sex ?\-?workers?|prostitut(es?|ion))\b/i,

  # the following are not in the original list
  :abuse => /\b((domestic|sexual) (violence|abuse)|violence against women|honou?r killings?|child abuse)\b/i,
  :addiction => /\b(addict(ion)?|(alcohol|drug|substance) (misuse|abuse)|alcohol(ism)?|drugs?|narcotics?|abstinence)\b/i,
  :learningdisabilities => /\b((learning|intellectual) (difficult|disabilit|disorder)(ies|y)?)\b/i,
  :isolation => /\b(isolat(ion|ed)|transport|lonel(y|iness))\b/i,

  # not really beneficiaries
  :artsculture => /\b(arts?|theatre|music(al)?|museums?|galler(y|ies)|festivals?|photograph(s|ic)?|carnivals?|paintings?|drawing|concerts?|camera|danc(e|ing|es)|drama(tic)?|exhibition|artists?|jazz|film|historical|media)\b/i,
  :sportrecreation => /\b(cricket|rugby|football|Tennis|swimming|bowling|gym|golf|netball|recreation(al)?|athletics|running|squash|play|bikes?|bicycles?|outdoor adventure|squash)\b/i,
  #:research => /\b(university|chemistry|physics|research(ing|ers)?|Genomics)\b/i,
}

GENDER_REGEXES = {
  # the following identify genders
  :Male => /\b(m(e|a)n|boys?|fathers?|males?|lads?)\b/i,
  :Female => /\b(wom(e|a)n|girls?|lad(y|ies)|mothers?|females?|lesbians?)\b/i,
  :Transgender => /\b(trans\-?(sexual|gender)?)\b/i,
}

AGE_REGEXES = {
    # the following identify ages or life stages
    :baby => {:regex => /\b(bab(ies|y)|neo\-?nat(al|e)|childbirth|infants?|toddlers?|preschoolers?|newborn)\b/i, :age_from => 0, :age_to => 3},
    :children => {:regex => /\b(child(ren)|junior|kids)\b/i, :age_from => 4, :age_to => 11},
    :youngpeople => {:regex => /\b(young ?\-?people|youth|teen\-?agers?|adolescen(ce|ts)|juveniles?|puberty)\b/i, :age_from => 12, :age_to => 25},
    :adults => {:regex => /\b(adult)\b/i, :age_from => 25, :age_to => 65},
    :elderly => {:regex => /\b(elderly|old(er)? ?\-?people|pensioners?|senior citizens?|(octo|nona)genarian|((second|2nd|1st|first) world war|WW(II|2)) veteran)\b/i, :age_from => 65, :age_to => 100},
    #:family => {:label => /\b(famil(y|ies))/i, :age_from => 0, :age_to => 3},
}

# the selected age groups with their age ranges
AGE_CATEGORIES = [
    {:label => "All ages", :age_from => 0, :age_to => 150},
    {:label => "Infants (0-3 years)", :age_from => 0, :age_to => 3},
    {:label => "Children (4-11 years)", :age_from => 4, :age_to => 11},
    {:label => "Adolescents (12-19 years)", :age_from => 12, :age_to => 19},
    {:label => "Young adults (20-35 years)", :age_from => 20, :age_to => 35},
    {:label => "Adults (36-50 years)", :age_from => 36, :age_to => 50},
    {:label => "Mature adults (51-80 years)", :age_from => 51, :age_to => 79},
    {:label => "Older adults (80+)", :age_from => 80, :age_to => 150}
]
