import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.core.display import display
from tqdm import tqdm
from WindPy import w

w.start()
w.isconnected()


class Snowball(object):

    def __init__(self, preset=None):
        if preset is None:
            preset = ['000905.SH', 105, 80, 15, 4,
                      '20200525', '20220525', 20, 0]
        self._code = preset[0]
        self._knock_out = preset[1] * 1e-2
        self._knock_in = preset[2] * 1e-2
        self._r = preset[3] * 1e-2
        self._f = preset[4] * 1e-2
        self._start_date = preset[5]
        self._maturity_date = preset[6]
        self._sigma = preset[7] * 1e-2
        self._div = preset[8] * 1e-2
        self._s0 = 1
        self._ctime = pd.Timestamp.now()

    def dateprocessor(self):
        stime = pd.Timestamp(self._start_date) + pd.Timedelta(hours=15, minutes=30)
        cdate = pd.Timestamp(self._ctime.strftime('%Y%m%d')) + pd.Timedelta(hours=15, minutes=30)
        cprice = w.wsq(self._code, 'rt_pre_close').Data[0][0]
        sprice = w.wss(self._code, 'pre_close', tradeDate=self._start_date).Data[0][0]
        preflag = 0
        df1 = 'None'
        if self._ctime < stime:
            tdays = w.tdays(self._start_date, self._maturity_date)
        else:
            if self._ctime < cdate:
                ctime = self._ctime
                ptime = self._ctime - pd.Timedelta(days=1)
            else:
                ctime = self._ctime + pd.Timedelta(days=1)
                ptime = self._ctime
            self._s0 = cprice / sprice
            preflag = 1
            predays = w.tdays(self._start_date, ptime.strftime('%Y%m%d'))
            tdays = w.tdays(ctime.strftime('%Y%m%d'), self._maturity_date)
            pre_in = pd.to_datetime(predays.Times) + pd.Timedelta(hours=15, minutes=30)
        in_ob = pd.to_datetime(tdays.Times) + pd.Timedelta(hours=15, minutes=30)
        out_ob = []
        pre_out = []
        key = stime + pd.Timedelta(days=30)
        while key < self._ctime:
            key0 = key
            while key0 not in pre_in:
                key0 += pd.Timedelta(days=1)
            pre_out.append(key0)
            key += pd.Timedelta(days=30)
        while key < in_ob[-1]:
            key0 = key
            while key0 not in in_ob:
                key0 += pd.Timedelta(days=1)
            out_ob.append(key0)
            key += pd.Timedelta(days=30)
        df2 = date_idt(in_ob, out_ob)
        if preflag:
            df1 = date_idt(pre_in, pre_out)
        return df1, df2, preflag

    def pricing(self, n):
        df1, df2, preflag = self.dateprocessor()
        val = 0
        has_in = 0
        if preflag:
            display(df1)
            k = df1.shape[0]
            history = w.wsd(self._code, 'close',
                            df1.index[0], df1.index[-1]).Data
            history = np.divide(history, history[0][0])
            history = history[0].tolist()
            for i in range(k):
                if history[i] > self._knock_out and df1.iloc[i, 0]:
                    print('该产品已经敲出！')
                    t = caldays(df1.index[0], df1.index[i]) / 365
                    val = (1 + t * self._r) * np.exp(-t * self._f)
                    break
                elif history[i] < self._knock_in and has_in == 0:
                    has_in = 1
                else:
                    pass
        if val == 0:
            display(df2)
            m = df2.shape[0]
            interval = np.array([df2['interval(Days)']]) / 365
            mu = interval * (self._f - self._div - self._sigma ** 2 / 2)
            mcm = mu + np.random.randn(n, m) * (interval ** 0.5) * self._sigma
            mcm = np.exp(np.matmul(mcm, np.tri(m).T)) * self._s0
            for i in tqdm(range(n)):
                outflag = 0
                out_date = ''
                if has_in:
                    inflag = 1
                else:
                    inflag = 0
                for j in range(m):
                    if mcm[i][j] > self._knock_out and df2.iloc[j, 0]:
                        outflag = 1
                        out_date = df2.index[j]
                        break
                    elif mcm[i][j] < self._knock_in and inflag == 0:
                        inflag = 1
                    else:
                        pass
                if outflag == 1:
                    t = caldays(self._start_date, out_date) / 365
                    fv = 1 + t * self._r
                    val += fv * np.exp(-t * self._f)
                elif outflag == 0 and inflag == 1:
                    t = caldays(self._start_date, self._maturity_date) / 365
                    val += mcm[i][-1] * np.exp(-t * self._f)
                else:
                    t = caldays(self._start_date, self._maturity_date) / 365
                    val += (1 + self._r) * np.exp(-t * self._f)
            val = val / n

        return val - 1


def date_idt(in_ob, out_ob):
    is_out_ob = []
    interval = []
    front = in_ob[0] - pd.Timedelta(days=1)
    for date in in_ob:
        date_delta = date - front
        interval.append(date_delta.days)
        front = date
        if date in out_ob:
            is_out_ob.append(1)
        else:
            is_out_ob.append(0)
    return pd.DataFrame(np.array([is_out_ob, interval]),
                        index=['is_out_ob', 'interval(Days)'],
                        columns=in_ob.strftime('%Y%m%d')).T


def caldays(date1, date2):
    date1 = pd.Timestamp(date1)
    date2 = pd.Timestamp(date2)

    delta = date2 - date1
    return delta.days


def main():
    st = pd.Timestamp.now()
    set1 = ['000905.SH', 105, 75, 14, 4.8, '20210725', '20220725', 20, 0.6]
    s = Snowball(set1)
    n = int(1e6)
    print('该雪球价值为：%.4f' % s.pricing(n))
    et = pd.Timestamp.now()
    tt = et - st
    print('共花费%ds' % tt.seconds)


if __name__ == '__main__':
    main()
