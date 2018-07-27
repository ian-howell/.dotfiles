#!/usr/bin/python3

#
# o I don't know how to apply any ":" perms...
# Best "requests" doc: http://docs.python-requests.org/en/master/user/quickstart/#more-complicated-post-requests
#
# TODO
# X store complete endpoint info in AAFClient, just in case we want it later
# o add prompt for getting password
# o add env variable for init file
# o add non-GET api calls
# o be pythonic, remove all getter/setter
# o write exception class - https://julien.danjou.info/blog/2016/python-exceptions-guide

import argparse
import configparser
import fire
import haversine
import json
import os
import pprint
import random
import requests
import string
import sys
import time
from sortedcontainers import SortedList

class AAFClient:
    user = str()
    password = str()
    timeout = 30
    components = [ 'service', 'gw', 'gui' ]
    envToVanityName = dict( [ ('devl', 'aaf.dev.att.com'),
                              ('test','aaftest.test.att.com'),
                              ('ist', 'aafist.test.att.com'),
                              ('prod', 'aaf.it.att.com') ] )

    def __init__( self, user, password, env ):
        self.user = user
        self.password = password
        self._apiEndpoints = list()
        self._gwEndpoints = list()
        self._guiEndpoints = list()
        self._allEndpointInfo = list()

        try:
            vanity = self.envToVanityName[ env.lower() ]
        except KeyError:
            print( "ERROR: Unknown environment: ", env )
            sys.exit()


        for c  in self.components:
            url = "https://{}/locate/com.att.aaf.{}:2.0".format( vanity, c )
            try:
                result = self.call_AAF( url )

            except:
                print( "ERROR: can't call locate:url={}; error={}".format( url, sys.exc_info()[0] ) )
                sys.exit()

            else:
                if ( result != None and result.status_code == 200 ):
                    val = result.json()["endpoint"]
                    self.allEndpointInfo.append( val )

                    for x  in val:
                        if ( c == "service" ):
                            self.apiEndpoints.append( '{}:{}'.format(  x['hostname'], x['port'] ) )

                        elif ( c == "gw" ):
                            self.gwEndpoints.append( '{}:{}'.format(  x['hostname'], x['port'] ) )

                        elif ( c == "gui" ):
                            self.guiEndpoints.append( '{}:{}'.format(  x['hostname'], x['port'] ) )
                else:
                    print( "ERROR: can't call locate:url={}; error={}; {}".format( url, result.status_code, result.text ) )
                    sys.exit()

    def call_AAF( self, url ):
        response = requests.get( url, auth=( self.user, self.password ), timeout=self.timeout )
        return( response )

    @property
    def apiEndpoints( self ):
        return( self._apiEndpoints )

    @property
    def guiEndpoints( self ):
        return( self._guiEndpoints )

    @property
    def gwEndpoints( self ):
        return( self._gwEndpoints )

    @property
    def allEndpointInfo( self ):
        return( self._allEndpointInfo )

    def dcFromLoc( self, latlon ):
        locToName = dict( [
            ("29.429636,-98.489327","SNANTXCA"),
            ("29.651818,-82.328181","GSVLFLAN"),
            ("29.749368,-95.365659","HSTNTX01"),
            ("30.267,-97.743","AUSFTXNK"),
            ("32.281586,-90.280683","JCSNMSDC"),
            ("32.779295,-96.800014","DLLSTXCF"),
            ("32.797541,-96.780433","DLLSTXTL"),
            ("32.888603,-117.16501","SNDGCA64"),
            ("32.911557,-96.871177","DLLTTX01"),
            ("33.095862,-96.681622","ALLNTXDW"),
            ("33.373969,-86.798214","BRHMALDC"),
            ("33.421134,-111.857128","MESAAZTL"),
            ("33.682913,-117.845959","IRVNCA11"),
            ("33.755,-84.39","ATLDGA93"),
            ("33.755866,-84.386004","ATLNGATL"),
            ("33.774241,-84.387141","ATLMGACX"),
            ("33.774577,-84.387329","ATLBGAPG"),
            ("33.824009,-84.368541","ATLDGAPB"),
            ("34.057840,-84.270465","ALPSGAGT"),
            ("34.085353,-84.255707","ALPRGAED"),
            ("34.087063,-84.275422","ALPSGACT"),
            ("35.252234,-81.384929","KGMTNC20"),
            ("35.318789,-80.762164","CHRLNCUN"),
            ("35.882739,-78.846838","MRVLNCBN"),
            ("35.893849,-78.827023","DRHMNCRT"),
            ("36.01235,-86.47295","NSVLTNBT"),
            ("36.023182,-86.791519","BRWDTNAI"),
            ("37.311182,-79.899895","RONKVADT"),
            ("37.445832,-122.160145","PLALCA02"),
            ("37.480141,-122.200036","RDCYCA02"),
            ("37.6335,-122.056","HYWSCA86"),
            ("37.66,-122.096839","HYWRCA02"),
            ("37.970523,-122.044959","CNCRCA73"),
            ("38.236322,-122.077782","FRFDCA60"),
            ("38.627345,-90.193774","STLSMORC"),
            ("38.62782,-90.19458","STLSMOSW"),
            ("38.752236,-90.440874","BGTNMOBU"),
            ("38.983237,-76.544124","ANNPMD01"),
            ("39.012272,-94.5617","KSCYMOAU"),
            ("39.019789,-77.45208","ASBNVACV"),
            ("39.096603,-94.578467","KSCYMO09"),
            ("39.559766,-104.839345","CNNTCO44"),
            ("39.792906,-105.015873","DNVRCOZJ"),
            ("40.397355,-74.135696","MDTWNJ21"),
            ("40.397355,-74.135696","MDTWNJAO"),
            ("40.397355,-74.135696","MDTWNJAS"),
            ("40.397355,-74.135696","MDTWNJAW"),
            ("40.4021023,-74.1433509","MDTTNJGO"),
            ("40.778664,-74.070803","SCCSNJEM"),
            ("41.075317,-81.534646","AKRNOHAH"),
            ("41.802607,-88.094941","LSLEILAA"),
            ("41.806650,-88.180681","WNVLILAC"),
            ("42.112343,-87.871769","NBRKILNT"),
            ("42.463933,-83.224433","SFLDMIBB"),
            ("43.056945,-88.229159","PEWKWIAC"),
            ("43.73747,7.163546","LGDEFR02"),
            ("47.680891,-122.147241","RDMDWAJC"),
            ("47.774566,-122.186614","BOTHWAKY"),
            ("47.778998,-122.1828830","BOTHWA07"),
            ("50.127339,8.605120","FRNFGEAA"),
            ("52.30897,-1.940936","RDCHENAX"),
            ("61.231376,-149.872653","ANCRAKZB"),
            ] )

        byDistance = dict()
        for geo, name in locToName.items():
            lat1, lon1 = geo.split( "," )
            lat2, lon2 = latlon.split( "," )

            d = haversine.distance( lat1, lon1, lat2, lon2 )
            byDistance[d] = name

        minVal = 99999999999999999999999999999
        for k,v in byDistance.items():
            if ( k < minVal ):
                minVal = k

        return( byDistance[minVal] )

    def get_user_perms( self, user ):
        res = self.call_AAF(  "https://{}/authz/perms/user/{}?ns=true".format( random.choice( self.apiEndpoints ), user ) )
        return( UserPermissions( res ) )

    def get_ns( self, ns ):
        res = self.call_AAF( "https://{}/authz/nss/{}".format( random.choice( self.apiEndpoints ), ns ) )
        if ( res.status_code == 200 ):
            return( Namespace( res ) )
        else:
            raise ValueError( "Cannot find ns '{}'. Error: {} Error msg: {}"
                              .format( ns,
                                       res.status_code,
                                       res.text ) )

    def get_creds( self, ns ):
        res = self.call_AAF( "https://{}/authn/creds/ns/{}".format( random.choice( self.apiEndpoints ), ns ) )
        return( Credentials( res ) )

    def get_creds_by_mechid( self, mechid ):
        res = self.call_AAF( "https://{}/authn/creds/id/{}".format( random.choice( self.apiEndpoints ), mechid ) )
        return( Credentials( res ) )



class UserPermissions:
    def __init__( self, res ):
        self.perms = dict()
        self.namespaces = set()
        self.ns_access = set()
        if ( res != None ):
            self.perms = res["perm"]
            for p in res["perm"]:
                if ( "access" in p["type"] ):
                    self.ns_access.add( p["ns"] )

            for a in res["perm"]:
                self.namespaces.add( a["ns"] )
#                print( "ns: {} type: {}".format( a["ns"], a["type"] ) )

        else:
            print( "init UserPermissions, result string None" )

    def get_namespaces( self ):
        return( self.namespaces )

    def get_perms( self ):
        return( self.perms )

    def get_ns_access( self ):
        return( self.ns_access )

    def get_perms_by_ns( self, ns ):
        plist = list()
        for p in self.perms:
            if ( ns == p["ns"] ):
                plist.append( "{}|{}|{}|".format( p["type"], p["instance"], p["action"] ) )

        return( plist )

class Namespace:
    name = str()
    owners = SortedList()
    admins = SortedList()

    def __init__( self, result ):
        if ( result != None and result.status_code == 200 ):
            result=result.json()

            self.name = result["ns"][0]["name"]
            if ( result["ns"][0].get( "admin" ) ):
                for a in result["ns"][0]["admin"]:
                    self.admins.add( a )
            if ( result["ns"][0].get( "responsible" ) ):
                for o in result["ns"][0]["responsible"]:
                    self.owners.add( o )
        else:
            raise ValueError( "Cannot find ns. Error: {} Error msg: {}"
                              .format( result.status_code,
                                       result.text() ) )

    def get_name( self ):
        return( self.name )

    def get_owners( self ):
        return( self.owners )

    def get_admins( self ):
        return( self.admins )


#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
#


#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
#
class Credentials:
    ns = str()
    creds = SortedList()

    def __init__( self, result ):
        credTypes = { '2'   : 'pass',
                      '200' : 'x509' }

        try:
            if ( result != None ):
                for x in result.json()['user']:
                    try:
                        credFlavor = credTypes[ str( x['type'] ) ]
                    except:
                        print( "error: value {} has no replacement in credTypes".format( x['type'] ), file=sys.stderr )
                        credFlavor = "UNKN"

                    c = "{id} [{kind}] expires {expires}".format( id=x['id'], expires=x['expires'], kind=credFlavor )

                    self.creds.add( c )
            else:
                print( "ERROR: __init__ Credentials, result is None" )
                return None
        except:
            print( "ERROR: __init__ Credentials, result={}, error={}".format( result, sys.exc_info()[0] ) )


    def get_creds( self ):
        return( self.creds )

#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#

def file_exists( parser, arg ):
    f = os.path.expanduser( arg )
    if ( not os.path.exists( f ) ):
        parser.error("File '{}' does not exist.".format( f ) )
        return False

    return f

def parseArgs():
    parser = argparse.ArgumentParser( description="Test AAF's api processes")
    parser.add_argument( '-p', '--prod', action='store_true',  required=False)
    parser.add_argument( '-i', '--ist',  action='store_true',  required=False)
    parser.add_argument( '-t', '--test', action='store_true',  required=False)
    parser.add_argument( '-c', '--config-file',
                         dest='conf',
                         nargs='?',
                         help='Config file containing authentication settings, etc',
                         default='~/.private/my.ini',
                         type=lambda x: file_exists( parser, x ),
                         required=False )

    return parser, parser.parse_args()

#
#
#
def main():
    parser,args = parseArgs()

    hosts = str()
    config = configparser.ConfigParser()

    try:
        config.read( args.conf )

        user = config['authentication']['user']
        password = config['authentication']['password']

        for k in args.__dict__:
            if ( k in ['test','ist','prod'] ):
                if ( args.__dict__[k] ):
                    if ( len( hosts ) > 0 ):
                        hosts += "," + config['machines'][k + 'GW']
                    else:
                        hosts += config['machines'][k + 'GW']
    except:
        print( "Invalid config file: ", args.conf )
        print( sys.exc_info() )

    client = AAFClient( user, password, "ist" )
    user1 = client.get_user_perms( "m83083@np.grid.att.com")
    user2 = client.get_user_perms( "m12098@usl.det.att.com")

    # print( "user1" )
    # print( user1.get_perms() )
    # print()
    # print( user1.get_namespaces() )
    # print()
    # print( user1.get_ns_access() )
    # print()
    # print( "user2" )
    # print( user2.get_perms() )
    # print()
    # print( user2.get_namespaces() )
    # print()
    # print( user2.get_ns_access() )

# o can user1 see user2's perms:
# - get UserPermissions for user1
# - get UserPermissions for user2
# - foreach user2.get_namespaces()
# -     is ns in user1.ns_access()
#


#############################################################################################

if __name__ == "__main__":
    fire.Fire()


#        ns = results["perm"][0]["ns"]


    # print( res )
    # print( "res is a ", type( res ) )
    # print()

    # ns = res["ns"]
    # print( ns )
    # print( "ns is a ", type( ns ) )
    # print()

    # print( "ns name", res["ns"][0]["name"] )
    # print( "responsible ", res["ns"][0]["responsible"] )
    # print( "responsible is a ", type( res["ns"][0]["responsible"] ) )
    # print( "admin ", res["ns"][0]["admin"] )
    # print( "admin is a ", type( res["ns"][0]["admin"] ) )

    # for a in res["ns"][0]["admin"]:
    #     print( "admin: ", a )








    # ns = client.get_ns( "com.att.aaf")
    # print( "ns name:", ns.get_name( ) )
    # print( "ns owners:", ns.get_owners( ) )
    # print( "ns admins:", ns.get_admins( ) )

    # if ( "cv7462@csp.att.com" in ns.get_owners() ):
    #     print( "chris owns" )

    # if ( "cv7462@csp.att.com" in ns.get_admins() ):
    #     print( "chris admins" )

    # for a in ns.get_admins():
    #     print( "admin: ", a )
