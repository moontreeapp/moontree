# import requests
# open a web browser and navigate to the page
import webbrowser
import time

for x in [
    'ESpoMP9fLVQYDBRJHbqv6fyycRw5gbLAbt',
    'EHWMxZK4iYupGDC5MocgK2syANcfDtPX68',
    'EY6ki3ckSYcwDfNs86gFBGfCSFo2FQbNWT',
    'EXoCNckXADd3aETaPkYMWNZnbUftyfXkpx',
    'ERwiWnnMthq8kR1xo1fAZyQAPDsfMm1e3y',
    'EXKoCfE4bP8qW2xsQnCrPZofqrARYrZEDP',  # 44299379.06000000
    'ENkg4KtHBdd7wGgDfcyhJdgAkgR7KdZCyB',  # 3682186.12000000
    'EQiH8mhiELoLTkcDkXHZpCj3WFQC2oZ5gk',
    'ERuSfkewJACvvzrqrRLNDu8gHx3J6weZ9y',
    'EUGwNR5JfQXzf9Euj3nUMHEmxmhR7XvYBd',
    'EfUwoUwifHves88GjyFhFD94ZDSxtQAVu1',  # 8251648.04688800
    'ERxNPdzMfo6TvsBUmqysF1UfQsokjfATu1',
    'EXjVQnj2LCwEsSUVZbavWDmz9sRcmbax2j',
    'ELZ87MabSm2eSLigaN3mZvHszdG87212Ve',  # 7432606.88000000
    'EeH7FwrjNPwUz9j236gTBZNct4CeLZN4cv',
    'Ec6quqv525p8a9K3sbbgUKXFZnC3oN2zGL',  # 4499999.99000000
    'EMU4BaFYCpGMUfcaEKW6R1PVcJsU8uBuZG',
    'EX3w9NBgsLgkuXaQGBqwfcZdmLEh6h4FSC',
    'ESjc1gRH7jubmurVAqX7dCB94qQjXnG3GC',
    'EYEnSjHWt4Fi6iwXL9WfPfvsCD3pzcGCDs',  # 4506121.26260000
    'EJSooxjk5H6ha24WNJp3k9xuFZMoHpQv64',
    'Efqk7utyyhU6uBQyvHgo8SBCN7jLHk27fT',
    'EeBKqLoxyBW2hbaYvcxe2SxjjQuVGbco9P',
    'EgVVuivWQJcUaDTRjczMxqPMNqG2w7WieQ',
    'EPaVbUdLUPDQpdyBSmh59YG8c7B7UBvNbb',
    'ESVvqooM2BrGywaPi56CEGXqHdhJpTXhGW',
    'EZFf5LWDyoHPpjBABRXJZCrYM1zUCPbTbM',  # 148934745.09840840
    'EddTvbMjtdkamhoXufJ3kwAfJ3Rugn9v3W',
    'EQELTPCNLvY5e3wfrYiKu3FYjjbv9fxKyi',  # 17000632.15473200
    'EdW2rQ7f6M8gYM7Q58odh8xCP2tqz9E3Gx',
    'Ecckm2edovey3WpQ5X288pVuBgheUG5C1Q',
    'EbmD7yjCeG2te4vDGF8gKm6CRf3Rnkp3n3',
    'EHS9NR2c7hvvm9QLNCAHiHeAYWYT7nfmAj',  # 3999998.99000000
    'EdEFCBEVnJ6Dzj4pEvAhRPzwQotWhp86ki',  # 32950065.27350000
    'EbHg5WGPCSCdaDSVfYYh47rymrSJCQEUdC',
    'EQb61Qof7QAXi9PYEEY6RqsoKYtZP8nu8o',
    'EdajUo4fQDxmAHftxUVwjTxqJHneTViJhC',
    'ERi4VkEXaPGBctFKMjLn7nY6vrqZdpV8FZ',
    'EV75LWNbF3YirPfQHYsZBMCrrZE5eKVhQX',
    'EWSHNJEDBjTsQwzVPoDY1Z8a5dgdicv4uz',
    'EZX2R6AB6dfQ6cVheWFcovLfCdJgeBMRUX',
    'ERckA2yvA22o96e5sCN2KjB7p4MFJFcBv1',  # 100.00000000
    'Eapw8yvaB4BP88DW8ReAaqrsvbTiPSG5AV',
    'EZtRHVskSivUK64GrSvxpF8dVWukxePtVy',
    'EeFAPTdi74ftXvNRdfQ8fs9S6oWUnqoQyh',  # 4943863.98992400
    'EdP7mir4okJDzdcr3f1HouxybLC8BANssd',  # 3999.99502800
    'EMC6JYNFXh5NFRaFiSeCZKNrAnnSpQtybG',
    'Ef6snbJsRSyeeuJq2MLz4NbfrwQX1X7V8m',
    'EekrZ9ik5uwWtxySu677RziGvdstwqpWnF',  # 4535503.02374600
    'EUvq8qCU3ypu9JGiuMs5uf1CyrzSZj31Z4',
    'EMaZD6FghNNpNEJcYjknYi6RBnDBFuPHuf',
    'EcZaz3VWTZw1MftkPQkhMARTcCPd15j94H',
    'EJnNLBfPNdUn6qSa8bwrJruEt51WK4pxYQ',
    'EQQUpAZ8erHhbYkoa2f4GcQptveoHL6F4f',
    'EUL99nLuCGHHfxxA8dYK93VRKtagLv8dqy',  # 18.98966000
    'EQq2zG5bV95dSHYwDcTLgGqzKCYzoJM44Q',
    'EKpdL4DgRCANSYb4j2ejyaorGjXo8oPc8P',
    'EPkbq7U3ZWC4e5AFsGoD866HQjCNzVTrFu',
    'ESqkpDEQh5oFvzVs71JjuiF7UZV89T2SSA',  # 1784504.33383000
    'Ea3QoeuDQhthvbbwLmCfoscciHTita6LGD',
    'EN8nhdbZGXFaYDEHiewxjLfS8xZcvZ1AK5',
    'EeRw4mmswsh7fWUecRastBKeTH7rqapLMD',  # 1609869.65973673
    'EedrCUqeTYurniSNhskZfjVgdH3VHMXkyD',
    'EWaqgUzNcC9MdPzdDzefA7Uef9dne1pb4h',
    'EfVhKEgjmLmJyFrVcepKNDxo8NGgYF4JUz',
    'EZgQXm35VoyD32a3mh2dr9f5ktK5uSgzAb',
    'EYx6mNSMffWXunbPmFfrCzVgQvkNsJzD4u',
    'EewoquUcGCa83QYvfsmQ4F4EpPC3antpRJ',
    'EXEukSSK4Bz8qXrHqEfEhLrXcaeuBmPgRt',
    'EXFRSuiP7ddyvgWYX6avz6vGtDvMGCQjBV',
    'EV2mmZbZZQwt4eNTos4wg8hK1rfPjEfNrU',
    'ERwp5u4pQnzdX5FHqZS8gBnHHXNaJtMVoH',
    'ELACRCA58wfhQtJSGqwpGDYS5sXEGqxms7',
    'EVFfzja4exAkPJKxsRAyiY2Tu4WkkpD9RB',
    'EgGWu89wK4Xu3j2vG9uH6SFJNAgP1eMswH',
]:
    # try:
    #    r = requests.get(f'https://evr.cryptoscope.io/address/?address={x}')
    #    print(r.text)
    #    print('t1-------------------------------------------')
    #    t = r.text.split('bal_row')[1]
    #    print(t)
    #    print('t2-------------------------------------------')
    #    t = t.split(
    #        '<h1 class="ml-1 mt-3 h1-responsive mb-0 font-weight-bold">')[1]
    #    print(t)
    #    print('a-------------------------------------------')
    #    a = t.split('<')[0]
    #    print(a)
    #    print('s-------------------------------------------')
    #    s = t.split('<small>')[1].split('<')[0]
    #    print(s)
    #    print('...-------------------------------------------')
    #    print(f'{x}: {a}.{s}')
    # except:
    #    print(f'{x}: 0.0')
    time.sleep(1)
    webbrowser.open(f'https://evr.cryptoscope.io/address/?address={x}')


# 4429937906000000 + 368218612000000 + 825164804688800 + 743260688000000 + 449999999000000 + 450612126260000 + 14893474509840840 + 1700063215473200 + 399999899000000 + 3295006527350000 + 10000000000 + 494386398992400 + 399999502800 + 453550302374600 + 1898966000 + 178450433383000 + 160986965973673
