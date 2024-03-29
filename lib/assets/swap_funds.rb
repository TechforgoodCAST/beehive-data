# fund names to replace when going through the data
# for each funder you can either have
# - a string (replace all with this),
# - a dict (perform name replacement)
SWAP_FUNDS = {
    "Oxfordshire Community Foundation" => "",
    "BBC Children in Need" => {
        "zPositive Destinations" => "Positive Destinations",
        "zFun and Friendship" => "Fun and Friendship"
    },
    "Lloyds Bank Foundation for England and Wales" => {
        "ZMSW - Community" => "Community",
        "XA7 - Criminal Justice" => "Criminal Justice",
        "XA1 - Community" => "Community",
        "XA2 - Community" => "Community",
        "XA12 - Community" => "Community",
        "ZHNWL - Young Offenders" => "Young Offenders",
        "Enable South" => "Enable",
        "XA10 - Criminal Justice" => "Criminal Justice",
        "ZSCSWL - Community" => "Community",
        "ZKSEL - Young Offenders" => "Young Offenders",
        "XA0 - Older People Programme" => "Older People Programme",
        "XA4 - Criminal Justice" => "Criminal Justice",
        "ZLNM - Community" => "Community",
        "ZNWS - Community" => "Community",
        "XA6 - Community" => "Community",
        "XA7 - Community" => "Community",
        "XA10 - Community" => "Community",
        "ZHNWL - Community" => "Community",
        "ZKSEL - Community" => "Community",
        "XA9 - Criminal Justice" => "Criminal Justice",
        "ZSWC - Community" => "Community",
        "XA2 - Criminal Justice" => "Criminal Justice",
        "XA11 - Community" => "Community",
        "ZENEL - Community" => "Community",
        "ZENEL - Young Offenders" => "Young Offenders",
        "XA11 - Criminal Justice" => "Criminal Justice",
        "XA5 - Community" => "Community",
        "ZNEC - Community" => "Community",
        "ZLarge Grants Programme" => "Large Grants Programme",
        "ZNWM - Community" => "Community",
        "Enable North" => "Enable",
        "ZLNS - Community" => "Community",
        "ZWMS - Community" => "Community",
        "XA9 - Community" => "Community",
        "ZEST - Community" => "Community",
        "ZYKS - Community" => "Community",
        "ZDCL - Community" => "Community",
        "ZCSM - Community" => "Community",
        "XA3 - Community" => "Community",
        "XA6 - Criminal Justice" => "Criminal Justice",
        "Invest South" => "Invest",
        "XA8 - Community" => "Community",
        "XA4 - Community" => "Community",
        "Invest North" => "Invest"
    },
    "Virgin Money Foundation" => {
        "North East Fund 2016" => "North East Fund",
        "North East Fund 2015" => "North East Fund"
    },
    "LandAid Charitable Trust" => {
        "Empty Properties Grants round 2015/16" => "Empty Properties Grants",
        "Grants 2014/15" => "Grants",
        "Open Grants round 2014/15" => "Open Grants",
        "Project Sponsorship 2014/15" => "Project Sponsorship",
        "Open Grants round 2013/14" => "Open Grants",
        "Joint funding 2013/14" => "Joint funding",
        "Open Grants round 2012/13" => "Open Grants",
        "Joint Funding 2014/15" => "Joint funding",
        "Project Sponsorship 2015/16" => "Project Sponsorship",
        "Open Grants round 2015/16" => "Open Grants",
    },
}
